#include "script_component.hpp"
/*
 * Author: Maxim
 * Straightens the tail of a path against a position about to be appended to it:
 * if any of the last few points can already see that position directly, every
 * point after it is detour and is dropped.
 *
 * This is what stops a traced path from keeping the wobble of the hand that drew
 * it. Dragging around a corner and then straightening out leaves a hook of
 * points doubling back on themselves; one line test per candidate removes it.
 *
 * The scan runs from the OLDEST candidate forward and stops at the first point
 * with clear line of sight, because that is the one that cuts the most. It stops
 * with `break`, not `exitWith` — inside a loop body `exitWith` unwinds only the
 * current iteration, so the scan would run on and each later, shorter cut would
 * overwrite the best one. That exact shape has shipped wrong five times in this
 * repository (Gotchas §2), twice as a silent last-wins reducer just like this
 * one would have been.
 *
 * Arguments:
 * 0: Path record, mutated in place <ARRAY>
 * 1: Position about to be appended, ASL <ARRAY>
 * 2: Drawing profile for the path's kind <ARRAY>
 *
 * Return Value:
 * Points were dropped <BOOL>
 *
 * Example:
 * [_path, _target, _profile] call rtz_path_fnc_smoothTail
 *
 * Public: No
 */

params ["_path", "_target", "_profile"];

private _steps = _profile select PROF_SMOOTH_STEPS;
if (_steps <= 0) exitWith {false};

private _points = _path select PATH_POINTS;
private _count = count _points;

// Nothing to straighten until there is a corner to straighten
if (_count < 2) exitWith {false};

private _hull = _path select PATH_HULL;
private _lift = [0, 0, _profile select PROF_CLEAR_HEIGHT];
private _liftedTarget = _target vectorAdd _lift;
private _lodNear = _profile select PROF_LOD_NEAR;
private _lodFar = _profile select PROF_LOD_FAR;

private _cut = false;

// The last point is the current head and is always visible from the target, so
// the scan stops before it — cutting to it would be a no-op.
for "_i" from ((_count - _steps) max 0) to (_count - 2) do {
    private _clear = (lineIntersectsSurfaces [
        (_points select _i) vectorAdd _lift,
        _liftedTarget,
        _hull,
        objNull,
        true,
        1,
        _lodNear,
        _lodFar,
        true
    ]) isEqualTo [];

    if (_clear) then {
        // Keep 0.._i, drop the detour after it
        _points resize (_i + 1);
        _path set [PATH_HEAD, _points select _i];
        _cut = true;
        break;
    };
};

_cut
