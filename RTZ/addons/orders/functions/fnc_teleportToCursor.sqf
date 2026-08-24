#include "script_component.hpp"
/*
 * Author: Maxim
 * Keybind handler: teleports the Zeus-selected units to the position under
 * the cursor, RTS-style. A unit is only moved if it is not in COMBAT
 * behaviour and the cursor position is within GVAR(teleportMaxDistance)
 * metres of it — a short tactical reposition, not a free map-wide teleport.
 * Successful use arms a distance-scaled cooldown per curator (see below).
 *
 * Applies to men on foot and to vehicles selected as a whole; individually
 * selected crew members are skipped (select the vehicle itself to move it).
 * With several units selected, each keeps its offset from the selection's
 * centre, so the formation shape is preserved instead of stacking everyone
 * onto one spot.
 *
 * Cursor resolution: ZEN's getPosFromScreen — it also intersects objects, so
 * pointing at a roof teleports onto it, and it handles the Zeus map view.
 *
 * Cooldown scales with distance travelled: 0 at zero distance up to
 * GVAR(teleportCooldown) seconds at GVAR(teleportMaxDistance) — a short hop
 * costs little, a full-range teleport costs the whole cooldown.
 *
 * Landing height: ground units get a vertical surface trace at their own
 * target x/y (the same "flush to any mostly-flat surface" test
 * zen_placement_fnc_updatePreview uses to ghost objects onto rooftops), so each
 * unit
 * lands on top of whatever is directly beneath it — terrain, a roof, a
 * bridge — not the bare terrain mesh a plain setPos ground-snap would fall
 * through to. Needed because the formation-preserving per-unit offsets each
 * land on a different footprint than the cursor's own object hit.
 *
 * Locality: runs on the curator's client. setPos has global arguments and
 * global effects, so moving server-local AI directly from here is safe — no
 * server round-trip needed. Runs only on the key press; no per-frame cost.
 *
 * Arguments:
 * None
 *
 * Return Value:
 * Press was handled (consumed) <BOOL>
 *
 * Example:
 * call rtz_orders_fnc_teleportToCursor
 *
 * Public: No
 */

// Zeus open, and not typing in ZEN's search box
CHECK_CURATOR_INPUT;

// Men on foot and whole vehicles from the current Zeus selection. objectParent
// is objNull for both; a crewed-in man fails the test and is skipped.
private _units = SELECTED_OBJECTS select {
    alive _x && {!isPlayer _x} && {isNull objectParent _x}
};
if (_units isEqualTo []) exitWith {false};

// Cooldown: a stored per-client timestamp checked only on the key press — no
// per-frame cost. Armed only when a teleport actually happens (below), so a
// fully blocked attempt does not burn the cooldown.
private _readyAt = GETGVAR(teleportReadyAt,0);
if (CBA_missionTime < _readyAt) exitWith {
    [LSTRING(MsgCooldown), ceil (_readyAt - CBA_missionTime)] call zen_common_fnc_showMessage;
    true
};

// Cursor → world position (AGL; only x/y are used)
private _pos = ASLToAGL ([] call zen_common_fnc_getPosFromScreen);

// Fallback matches the registered setting default (initSettings.inc.sqf) so a
// read before CBA_settingsInitialized behaves like the configured one. It is
// also the cooldown scale's divisor below, so it must never be 0 — the slider
// floor is 10.
private _maxDistance = GETGVAR(teleportMaxDistance,150);

// Selection centre — per-unit offsets from it preserve the formation shape
private _centre = [0, 0, 0];
{_centre = _centre vectorAdd getPos _x} forEach _units;
_centre = _centre vectorMultiply (1 / count _units);

// Every unit keeps its offset from centre, so cursor-to-centre distance is
// exactly how far each one travels — one range check and one cooldown
// scale for the whole group instead of per-unit work.
private _travelDistance = _centre distance2D _pos;
private _tooFarFlag = _travelDistance > _maxDistance;

// Vertical surface trace at a world x/y: the highest mostly-flat surface —
// roof, bridge, terrain — falling back to bare terrain height when the ray
// finds nothing usable (e.g. over water).
private _fnc_surfaceAt = {
    params ["_px", "_py", ["_ignoreObj", objNull]];

    private _terrainASL = getTerrainHeightASL [_px, _py];
    private _landPos = [_px, _py, _terrainASL];

    // `break`, not `exitWith`. lineIntersectsSurfaces returns its hits sorted by
    // distance from the BEGIN position — here 200 m up — so the first mostly-flat
    // surface is the HIGHEST one, which is the whole point of tracing downward.
    // This was an `exitWith`, which inside a forEach unwinds only the current
    // ITERATION (it is continue, not break — docs/Knowledge Base/Gotchas.md §2): the
    // loop ran on and every later, LOWER surface overwrote _landPos, so the trace
    // returned the lowest flat hit instead of the highest. A unit teleported onto a
    // multi-storey building landed on its ground floor, and one aimed at a bridge
    // landed under it.
    {
        _x params ["_intersectPos", "_surfaceNormal"];

        if (_surfaceNormal vectorDotProduct [0, 0, 1] > 0.5) then {
            _landPos = _intersectPos;
            break;
        };
    } forEach lineIntersectsSurfaces [[_px, _py, _terrainASL + 200], [_px, _py, _terrainASL - 10], _ignoreObj, objNull, true, 5];

    _landPos
};

private _moved = 0;
private _inCombat = 0;
private _tooFar = 0;

{
    // A vehicle's behaviour lives on its effective commander; an empty
    // vehicle (null commander) counts as not in combat
    private _behaviourUnit = if (_x isKindOf "CAManBase") then {_x} else {effectiveCommander _x};
    if (!isNull _behaviourUnit && {behaviour _behaviourUnit == "COMBAT"}) then {
        _inCombat = _inCombat + 1;
        continue;
    };

    if (_tooFarFlag) then {
        _tooFar = _tooFar + 1;
        continue;
    };

    private _target = _pos vectorAdd (getPos _x vectorDiff _centre);

    // ~0 AGL means a ground unit: surface-trace the target x/y so it lands on
    // top of whatever is there (terrain, a roof, ...) instead of falling
    // through to bare terrain. Anything already airborne keeps its altitude.
    private _curAGL = (getPos _x) select 2;
    if (_curAGL < 2) then {
        _x setPosASL ([_target select 0, _target select 1, _x] call _fnc_surfaceAt);
    } else {
        _x setPos [_target select 0, _target select 1, _curAGL];
    };
    _moved = _moved + 1;

    // Move-order feedback: ZEN's expected-destination icon
    [[["ICON", [_x, ICON_TELEPORT]]], HINT_DURATION, _x] call zen_common_fnc_drawHint;
} forEach _units;

// Something moved → arm the cooldown from now, scaled by how far the group
// actually travelled relative to the configured maximum
if (_moved > 0) then {
    private _cooldown = GETGVAR(teleportCooldown,10) * (_travelDistance / _maxDistance);
    GVAR(teleportReadyAt) = CBA_missionTime + _cooldown;
};

private _messages = [];
if (_moved > 0) then {_messages pushBack LLSTRING(MsgTeleported)};
if (_inCombat > 0) then {_messages pushBack LLSTRING(MsgInCombat)};
if (_tooFar > 0) then {_messages pushBack format [LLSTRING(MsgBeyondRange), _maxDistance]};
// Composed text goes in as a format ARGUMENT so a "%" inside a translation
// isn't re-scanned as a placeholder by showMessage's own format pass.
["%1", _messages joinString ", "] call zen_common_fnc_showMessage;

true
