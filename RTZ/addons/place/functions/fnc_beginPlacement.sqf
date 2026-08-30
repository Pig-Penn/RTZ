#include "script_component.hpp"
/*
 * Author: Maxim
 * Opens a placement session: works out who is taking part, seeds a ghost for
 * each of them in formation at the cursor, and installs everything the session
 * runs on — display handlers, the ghost renderer, and the per-frame tick.
 *
 * Every one of those is torn down by FUNC(endPlacement) and nowhere else.
 *
 * COMBAT units are refused HERE rather than at commit. The order this mode
 * replaces could only discover the refusal at the moment it teleported, so a
 * curator learned that half the selection was engaged only after the fact; a
 * session can say so up front, and the units simply get no ghost.
 *
 * Entirely client-local — no remoteExec, nothing networked. The one piece of
 * state that reaches outside this component is ZEN's own picker flag, held for
 * the session's lifetime so ZEN stands its pickers and its context menu down;
 * see the entry guard below.
 *
 * Arguments:
 * None
 *
 * Return Value:
 * Session opened (and so the press was consumed) <BOOL>
 *
 * Example:
 * call rtz_place_fnc_beginPlacement
 *
 * Public: No
 */

private _display = findDisplay IDD_RSCDISPLAYCURATOR;
if (!hasInterface || {isNull _display}) exitWith {false};

// One picker at a time. rtz_common's placement preview and ZEN's own position
// picker both install click handlers on this same display and both drive a ghost
// off the cursor; a session opened underneath either of them would fight it for
// the two ignore slots lineIntersectsSurfaces has and the ghosts would climb each
// other. EFUNC(common,placementPreview) states the contract in full.
if (GETEGVAR(common,previewActive,false) || {GETMVAR(zen_common_selectPositionActive,false)}) exitWith {false};

// ── Who is taking part ───────────────────────────────────────────────────────
// A Zeus selection arrives as two DISJOINT lists: a group picked by its group
// icon lands in SELECTED_GROUPS with none of its units in SELECTED_OBJECTS. The
// teleport this mode replaces read only the first list and so silently did
// nothing for a group picked that way. Merge, exactly as EFUNC(orders,
// toggleCombatMode) does.
private _objects = SELECTED_OBJECTS;
private _selGrps = SELECTED_GROUPS;
if (_selGrps isNotEqualTo []) then {
    _objects = +_objects;   // never mutate what a command returned
    {
        private _grp = _x;  // ALIAS: the inner loop rebinds _x
        if (_grp isEqualType grpNull) then {
            {_objects pushBackUnique _x} forEach units _grp;
        };
    } forEach _selGrps;
};

// Men on foot and whole vehicles. objectParent is objNull for both; a crewed-in
// man fails the test and is skipped, so a curator moves a vehicle by selecting
// the vehicle rather than by selecting somebody sitting in it.
private _units = _objects select {
    _x isEqualType objNull && {alive _x} && {!isPlayer _x} && {isNull objectParent _x}
};
if (_units isEqualTo []) exitWith {false};

// A vehicle's behaviour lives on its effective commander; an empty vehicle
// (null commander) counts as not in combat.
private _movable = [];
private _inCombat = 0;
{
    private _behaviourUnit = if (_x isKindOf "CAManBase") then {_x} else {effectiveCommander _x};
    if (!isNull _behaviourUnit && {behaviour _behaviourUnit == "COMBAT"}) then {
        _inCombat = _inCombat + 1;
    } else {
        _movable pushBack _x;
    };
} forEach _units;

if (_movable isEqualTo []) exitWith {
    [LSTRING(MsgInCombat)] call zen_common_fnc_showMessage;
    true
};

private _seeds = [_movable] call FUNC(seedPositions);
if (_seeds isEqualTo []) exitWith {false};

// ── Stand ZEN down ───────────────────────────────────────────────────────────
// Deliberately AHEAD of every flag this function sets. isPlacementActive reads
// the vanilla RscDisplayCurator_sections global and would throw if Zeus ever had
// the display up without it; a throw past the flags would strand GVAR(placing)
// and ZEN's picker flag true and kill every picker for the rest of the mission.
// Ordered this way the worst case is one session that fails to open.
// EFUNC(common,placementPreview) works through this at length.
if (call zen_common_fnc_isPlacementActive) then {
    (call zen_common_fnc_getActiveTree) tvSetCurSel [-1];
};

GVAR(placing) = true;
GVAR(grabbed) = -1;
GVAR(hovered) = -1;

// Read by zen_common_fnc_selectPosition for re-entry and by zen_context_menu's
// right-click handler, which will not open a menu over an active picker. Cleared
// outright by FUNC(endPlacement) rather than restored to a remembered value: the
// entry guard above refuses to start while it is true, so it was false before.
zen_common_selectPositionActive = true;

// ── Ghosts ───────────────────────────────────────────────────────────────────
// The recipe is EFUNC(common,placementPreview)'s, one per unit: a hidden Logic
// the ghost rides so it can be positioned cleanly, and an optional local model
// attached to it.
//
// Models are capped. The helper, the icon and the drag are what a session needs
// to work and they cost nothing per unit worth counting; the MODEL is the part
// whose cost scales, and a box select over a company should not spawn a company
// of local models on a machine that is already carrying both server and client
// load. Above the cap the icons alone stand in for the ghosts.
private _modelBudget = GETGVAR(ghostModelMax,12);
private _ghosts = [];

{
    _x params ["_unit", "_posASL"];

    private _helper = "Logic" createVehicleLocal [0, 0, 0];
    _helper hideObject true;
    _helper setPosASL _posASL;
    _helper setVectorUp (surfaceNormal _posASL);

    // The class test is not paranoia: typeOf answers "" for a terrain-placed
    // object, and "" createVehicleLocal hands back objNull, which would then be
    // attachTo'd and offset off a position that does not exist. Same guard, for
    // the same reason, as EFUNC(common,placementPreview)'s.
    private _class = typeOf _unit;
    private _model = objNull;
    if (_forEachIndex < _modelBudget && {_class != ""} && {isClass (configFile >> "CfgVehicles" >> _class)}) then {
        _model = _class createVehicleLocal [0, 0, 0];
        _model disableCollisionWith player;
        _model enableSimulation false;
        _model allowDamage false;

        // Keep ZEN from auto-registering this local object as curator-editable.
        // ZEN's auto-add class EH only runs on the server, so this only matters
        // when the curator is the host (matches ZEN's own setupPreview).
        if (isServer) then {
            _model setVariable ["zen_common_autoAddObject", false];
        };

        // Align the model centre to land contact so it sits on the surface
        private _offset = (getPosWorld _model select 2) - (getPosASL _model select 2);
        _model attachTo [_helper, [0, 0, _offset]];
    };

    // All three built ONCE, here, and never rebuilt. CLAUDE.md: keep format/str
    // off anything that runs per entity per tick, and the renderer is exactly
    // that. The colour pair is precomputed for the same reason — EFUNC(common,
    // sideColor) hands back a SHARED, READ-ONLY array, so varying its alpha means
    // building a new one, and doing that per ghost per frame is an allocation the
    // renderer should never have to make. The glyph is a config read behind ZEN's
    // cache, cheap but not free, and it never changes for the life of a session.
    ([_unit] call EFUNC(common,classInfo)) params ["_label", "_isLeader"];
    private _rgb = ([side _unit, _isLeader] call EFUNC(common,sideColor)) select [0, 3];
    private _colors = [_rgb + [GHOST_ALPHA_IDLE], _rgb + [GHOST_ALPHA_HOVER]];
    private _glyph = [_class] call zen_common_fnc_getVehicleIcon;

    // The ORIGIN, deliberately, not the seed the helper was just put at: the
    // range gate has to measure how far this unit would actually travel, and
    // seeding has already carried the ghost most of the way to the cursor.
    _ghosts pushBack [_unit, _helper, _model, getPosASL _unit, _label, _colors, _glyph];
} forEach _seeds;

GVAR(ghosts) = _ghosts;

// ── Handlers, renderer, tick ─────────────────────────────────────────────────
GVAR(inputEHs) = [_display] call FUNC(handleInput);
// Deliberately AFTER the ghosts are seeded, which is the last thing that reads
// the selection. Clearing it gets the mouse pointer right for the session: Zeus
// shows the CuratorSelect ring while units are held and its CuratorPlace arrow
// when nothing is, and a session about to put units down wants the second one.
// EFUNC(common,placementPreview) does the same, for the same reason, and states
// it at length. Not restored on cancel — the ring would come back with it.
setCuratorSelected [];
[QGVAR(ghosts), LINKFUNC(drawGhosts), RENDER_WORLD, RENDER_PRIORITY] call EFUNC(core,registerRenderer);
GVAR(placePfh) = [LINKFUNC(placeTick), 0, []] call CBA_fnc_addPerFrameHandler;

private _messages = [LLSTRING(MsgPlacing)];
if (_inCombat > 0) then {_messages pushBack LLSTRING(MsgInCombat)};
if (count _ghosts > _modelBudget) then {_messages pushBack LLSTRING(MsgIconsOnly)};
// Composed text goes in as a format ARGUMENT so a "%" inside a translation isn't
// re-scanned as a placeholder by showMessage's own format pass.
["%1", _messages joinString ", "] call zen_common_fnc_showMessage;

true
