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
 * Feedback: a 3-second drawHint icon over each affected unit using ZEN's own
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
 * call rtz_common_fnc_toggleCombatMode
 *
 * Public: No
 */

// Zeus open, and not typing in ZEN's search box
CHECK_CURATOR_INPUT;

private _units = SELECTED_OBJECTS select {
    _x isKindOf "CAManBase"
    && {alive _x}
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

// Index-parallel with _grps: the icon colour each group's members get below.
private _grpColors = [];
private _holdCount = 0;
private _openCount = 0;

{
    // Current state: broadcast var, seeded from the engine read the first time
    private _holdFire = _x getVariable [QGVAR(holdFire), combatMode _x == "BLUE"];
    private _newHold = !_holdFire;
    private _mode = ["YELLOW", "BLUE"] select _newHold;

    [QGVAR(toggleCombatMode), [_x, _mode, _newHold], _x] call CBA_fnc_targetEvent;

    _grpColors pushBack ([COLOR_OPEN_FIRE, COLOR_HOLD_FIRE] select _newHold);

    if (_newHold) then {
        _holdCount = _holdCount + 1;
    } else {
        _openCount = _openCount + 1;
    };
} forEach _grps;

{
    [[
        ["ICON", [_x, ICON_COMBAT_MODE, _grpColors select (_grps find group _x)]]
    ], HINT_DURATION, _x] call zen_common_fnc_drawHint;
} forEach _units;

private _messages = [];
if (_holdCount > 0) then { _messages pushBack format [LLSTRING(MsgHoldFireCount), _holdCount] };
if (_openCount > 0) then { _messages pushBack format [LLSTRING(MsgOpenFireCount), _openCount] };
// Composed text goes in as a format ARGUMENT so a "%" inside a translation
// isn't re-scanned as a placeholder by showMessage's own format pass.
["%1", _messages joinString ", "] call zen_common_fnc_showMessage;

true
