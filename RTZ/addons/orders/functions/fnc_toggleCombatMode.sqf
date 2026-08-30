#include "script_component.hpp"
/*
 * Author: Maxim
 * Keybind handler: toggles the Zeus-selected AI groups between forced hold
 * fire ("BLUE" — never fire, maintain formation) and the standard open-fire
 * posture ("YELLOW" — fire at will, maintain formation), without opening
 * ZEN's Combat Mode context-menu action first.
 *
 * Each group is read and flipped independently — its own current state
 * decides its own next state — so a mixed selection can't push a group
 * that's already forced to hold fire back into hold fire just because
 * another selected group wasn't.
 *
 * State is tracked in a broadcast group variable QGVAR(holdFire) rather than
 * read back from the engine: setCombatMode is a local-effect command (ZEN
 * dispatches it to the group owner too), so `combatMode _grp` read on the
 * curator's client is not authoritative when the group is local to a
 * dedicated server or a headless client. The owner machine sets the variable
 * public in the QGVAR(toggleCombatMode) handler (XEH_postInit.sqf), so the
 * curator's next read is always correct (mirrors fnc_flyHeight's per-vehicle
 * fly-height var — same "no reliable cross-locality engine getter"
 * situation). Seeded from the engine combatMode the first time, so a group
 * already set to hold fire via ZEN's context menu is picked up on the host.
 *
 * setCombatMode is a local-effect command, so each group gets a
 * QGVAR(toggleCombatMode) event targeted at the group itself — CBA delivers
 * it to whatever machine the group's units are local to (mirrors
 * fnc_switchStance / fnc_flyHeight; handler registered on every machine in
 * XEH_postInit). Groups with no AI (all-player) are skipped — the mode has
 * nothing to apply to.
 *
 * The selection is normalized first: a selected man contributes his own group, a
 * selected vehicle the groups of its crew, and a group picked by its group icon
 * (which lands in SELECTED_GROUPS, not SELECTED_OBJECTS) contributes itself.
 *
 * Feedback: a 3-second drawHint icon over each affected entity using ZEN's own
 * Combat Mode menu glyph, tinted the same way ZEN tints it — red for forced
 * hold fire ("BLUE"), white for open fire ("YELLOW").
 *
 * Arguments:
 * None
 *
 * Return Value:
 * Press was handled (consumed) <BOOL>
 *
 * Example:
 * call rtz_orders_fnc_toggleCombatMode
 *
 * Public: No
 */

// Zeus open, and not typing in ZEN's search box
CHECK_CURATOR_INPUT;

// A Zeus selection arrives as two DISJOINT lists: entities picked individually
// land in SELECTED_OBJECTS, while a group picked by its group icon lands in
// SELECTED_GROUPS with NONE of its units in the first list (same expansion, and
// the same reasoning, as rtz_core's selectionPoll). A picked VEHICLE is in the
// first list as the hull — its crew is not there at all.
//
// This used to read SELECTED_OBJECTS alone and keep only men, so a selected
// vehicle contributed nothing and the curator was forced to select its crew by
// hand, and a group-icon pick did nothing at all.
private _objects = SELECTED_OBJECTS;
private _selGrps = SELECTED_GROUPS;
if (_selGrps isNotEqualTo []) then {
    // Copied before appending: never mutate the array a command handed back. Skipped
    // entirely in the ordinary case where no group icon is part of the selection.
    _objects = +_objects;
    {
        // ALIAS: the inner loop rebinds _x to a unit (docs/Knowledge Base/Gotchas.md §2).
        private _grp = _x;
        if (_grp isEqualType grpNull) then {
            { _objects pushBackUnique _x } forEach units _grp;
        };
    } forEach _selGrps;
};

// EFUNC(common,collectUnits) is the shared normalizer: a selected man contributes
// himself, a selected vehicle its crew, and non-object / non-man entries are
// dropped. It already returns a unique list, so the group expansion above cannot
// double-count a unit that was also picked individually.
private _units = ([_objects] call EFUNC(common,collectUnits)) select {
    alive _x
    && {!isPlayer _x}
    && {!isNull group _x}
};
if (_units isEqualTo []) exitWith {false};

// Unique AI-bearing groups from the selection. Every _x already passed the
// !isPlayer filter above, so its own group is guaranteed to contain an AI
// unit — no need to re-scan `units _grp` looking for one (arrays take group
// equality; HashMaps reject groups as keys, which is why this isn't keyed by
// group).
private _grps = [];
{ _grps pushBackUnique group _x } forEach _units;

// Icon colour per group, keyed by group netId. Keyed rather than index-parallel
// with _grps for two reasons: the hint loop below walks UNITS, so a parallel array
// cost a linear `_grps find group _x` per selected unit, and an index-parallel
// pair is only correct for as long as both loops keep the same order — an
// invariant nothing here enforces. A netId key is what makes this a map at all,
// since HashMaps reject groups themselves as keys.
private _grpColorById = createHashMap;
private _holdCount = 0;
private _openCount = 0;

{
    // Current state: broadcast var, seeded from the engine read the first time
    private _holdFire = _x getVariable [QGVAR(holdFire), combatMode _x == "BLUE"];
    private _newHold = !_holdFire;
    private _mode = ["YELLOW", "BLUE"] select _newHold;

    [QGVAR(toggleCombatMode), [_x, _mode, _newHold], _x] call CBA_fnc_targetEvent;

    _grpColorById set [netId _x, [COLOR_OPEN_FIRE, COLOR_HOLD_FIRE] select _newHold];

    if (_newHold) then {
        _holdCount = _holdCount + 1;
    } else {
        _openCount = _openCount + 1;
    };
} forEach _grps;

// One icon per affected ENTITY rather than per unit: a mounted unit's icon draws
// at its vehicle, so a four-man crew would stack four identical glyphs on the one
// spot. `vehicle _x` is the man himself when he is on foot, so a foot selection
// behaves exactly as before. Passing the same object as the hint ID keeps a
// re-press replacing that entity's icon instead of layering another.
//
// Every unit here passed the !isNull group filter above and its group was pushed
// into the loop that filled the map, so the lookup always hits; the default is
// only there so a future filter change degrades to an uncoloured icon rather than
// a nil that aborts the rest of the hint pass.
private _drawn = [];
{
    private _veh = vehicle _x;
    if !(_veh in _drawn) then {
        _drawn pushBack _veh;
        [[
            ["ICON", [_veh, ICON_COMBAT_MODE, _grpColorById getOrDefault [netId group _x, COLOR_OPEN_FIRE]]]
        ], HINT_DURATION, _veh] call zen_common_fnc_drawHint;
    };
} forEach _units;

private _messages = [];
if (_holdCount > 0) then { _messages pushBack format [LLSTRING(MsgHoldFireCount), _holdCount] };
if (_openCount > 0) then { _messages pushBack format [LLSTRING(MsgOpenFireCount), _openCount] };
// Composed text goes in as a format ARGUMENT so a "%" inside a translation
// isn't re-scanned as a placeholder by showMessage's own format pass.
["%1", _messages joinString ", "] call zen_common_fnc_showMessage;

true
