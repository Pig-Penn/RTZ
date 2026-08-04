#include "script_component.hpp"
/*
 * Author: Maxim
 * Turns the drawn session into orders. Runs on the curator's client, which is
 * where the paths were drawn and the only machine that has them.
 *
 * One TARGETED event per unit, not a broadcast. Wargame remoteExecs its executor
 * to everyone and has each machine test locality and discard, so a thirty-unit
 * plan costs every client in the session thirty payloads to throw away; here the
 * only machine that hears about a path is the one that will run it.
 *
 * Each path is resampled by FUNC(reducePath) before it goes out. What crosses
 * the wire is a few dozen legs, not the several hundred points the line on
 * screen was drawn from.
 *
 * A path whose ends meet commits as a PATROL and cycles instead of stopping.
 * Detected here rather than on the far side so the executor is handed a decision
 * rather than a heuristic — and so the two ends are compared while both are
 * still in the space they were drawn in.
 *
 * Routability is re-checked immediately before ordering. A session can stay open
 * for minutes, and FUNC(planTick) prunes on a half-second stagger, so the last
 * word on whether a unit can still be ordered belongs here.
 *
 * Arguments:
 * None
 *
 * Return Value:
 * Paths ordered <NUMBER>
 *
 * Example:
 * private _n = call rtz_path_fnc_commitPaths
 *
 * Public: No
 */

private _ordered = 0;

{
    _x params ["_unit", "_hull", "_points", "", "_kind"];

    // A path nobody drew anything on is not an order to stand still
    if (_points isEqualTo []) then {continue};
    if ([_hull] call FUNC(pathKind) == KIND_NONE) then {continue};

    private _legs = [_points, (GVAR(profiles) select _kind) select PROF_COMMIT_SPACING] call FUNC(reducePath);

    // Closed and long enough to be a circuit rather than a scribble
    private _patrol = count _points >= PATROL_MIN_POINTS
        && {(_points select 0) distance2D (_points select -1) <= PATROL_CLOSE_DIST};

    [QGVAR(follow), [_unit, _hull, _legs, _kind, _patrol], _unit] call CBA_fnc_targetEvent;

    _ordered = _ordered + 1;
} forEach GVAR(paths);

_ordered
