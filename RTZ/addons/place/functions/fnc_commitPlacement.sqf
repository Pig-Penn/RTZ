#include "script_component.hpp"
/*
 * Author: Maxim
 * Moves every unit to where its ghost is standing, facing the way its ghost
 * faces, and arms the cooldown.
 *
 * THE POSITION IS TAKEN VERBATIM. getPosASL off the helper goes straight into
 * setPosASL on the unit, with no re-trace, no ground snap and no correction of
 * any kind. That is the entire point of the mode: the order this replaces threw
 * the curator's aim away and re-traced a vertical column at each unit's target,
 * taking the HIGHEST mostly-flat surface it found — which is a roof whenever
 * there is a building involved, no matter what the curator was pointing at. A
 * ghost the curator has already dropped on an interior floor needs no help
 * deciding where the floor is.
 *
 * Range is tested PER UNIT, measured from where that unit stood when the session
 * opened (GHOST_ORIGIN). The one-shot order tested once for the whole group
 * against the selection centre, which was meaningful only because every unit
 * moved by the same vector; here each ghost is dragged independently, so a group
 * test would let one unit be sent across the map as long as the average stayed
 * short. Refused units are counted, not moved — and the renderer has been
 * drawing them red since the moment they went out of range.
 *
 * Locality: runs on the curator's client. setPosASL has global arguments and
 * global effects, so moving server-local AI directly from here is safe — no
 * server round-trip needed.
 *
 * Called only by FUNC(endPlacement), and only on the committing path.
 *
 * Arguments:
 * None
 *
 * Return Value:
 * None
 *
 * Example:
 * call rtz_place_fnc_commitPlacement
 *
 * Public: No
 */

private _ghosts = GVAR(ghosts);
if (_ghosts isEqualTo []) exitWith {};

// Fallback matches the registered setting default (initSettings.inc.sqf) so a
// read before CBA_settingsInitialized behaves like the configured one. It is also
// the cooldown scale's divisor below, so it must never be 0 — the slider floor
// is 10.
private _maxDistance = GETGVAR(maxDistance,150);

private _moved = 0;
private _tooFar = 0;
private _maxTravel = 0;

{
    _x params ["_unit", "_helper", "", "_origin"];

    // A unit can die, or be deleted by another curator, while a session is open
    if (isNull _helper || {!alive _unit}) then {continue};

    private _posASL = getPosASL _helper;
    private _travel = _origin distance2D _posASL;

    if (_travel > _maxDistance) then {
        _tooFar = _tooFar + 1;
        continue;
    };

    _unit setPosASL _posASL;
    // Facing comes off the helper for the same reason the position does: the
    // curator turned the ghost to say which way this unit should end up looking,
    // and a ghost that was never rotated still holds the facing it was seeded
    // with in FUNC(beginPlacement) — the unit's own — so this is a no-op there
    // rather than a snap to north. setDir has global effects, like setPosASL, so
    // it needs no more locality handling than the line above.
    _unit setDir (getDir _helper);
    _moved = _moved + 1;
    if (_travel > _maxTravel) then {_maxTravel = _travel};

    // Move-order feedback: ZEN's expected-destination icon, on the unit itself
    [[["ICON", [_unit, ICON_PLACED]]], HINT_DURATION, _unit] call zen_common_fnc_drawHint;
} forEach _ghosts;

// Something moved → arm the cooldown from now, scaled by the FURTHEST any one
// unit actually travelled relative to the configured maximum. The furthest
// rather than the average: the cooldown prices the largest repositioning the
// curator just made, and averaging would let a long move be paid for by padding
// the selection with units that barely shifted.
if (_moved > 0) then {
    GVAR(readyAt) = CBA_missionTime + (GETGVAR(cooldown,10) * (_maxTravel / _maxDistance));
};

private _messages = [];
if (_moved > 0) then {_messages pushBack LLSTRING(MsgPlaced)};
if (_tooFar > 0) then {_messages pushBack format [LLSTRING(MsgBeyondRange), _maxDistance]};
if (_messages isEqualTo []) exitWith {};

// Composed text goes in as a format ARGUMENT so a "%" inside a translation isn't
// re-scanned as a placeholder by showMessage's own format pass.
["%1", _messages joinString ", "] call zen_common_fnc_showMessage;
