#include "script_component.hpp"
/*
 * Author: Maxim
 * Why this point cannot be dug, or "" if it can. One point of one cell;
 * FUNC(planTrench) runs it over each cell's floor and both wall positions.
 *
 * Returns the REASON rather than a boolean so the curator's preview can say what
 * is wrong — a gesture that just turns red tells him to move it, not why.
 *
 * Ported from the validation block of ace_trenches_fnc_blockTrench_place, with one
 * deliberate difference: ACE runs its `nearestObjects` check against `_origin2D`,
 * the START of the whole trench, rather than against the point it is testing (its
 * `nearestTerrainObjects` check on the line above uses the point correctly). That
 * looks like a copy-paste slip — it means a building halfway along an ACE trench
 * line is never seen, while an object at the origin vetoes every cell. This tests
 * the point it was given.
 *
 * Arguments:
 * 0: Position 2D <ARRAY>
 * 1: Test radius <NUMBER>
 * 2: Ignore safety checks <BOOL> (default false)
 *
 * Return Value:
 * Reason the point is unusable, "" when it is clear <STRING>
 *
 * Example:
 * private _reason = [[1000, 2000], 7.5] call rtz_dig_fnc_cellObstruction
 *
 * Public: No
 */

params ["_pos", "_radius", ["_force", false]];

// Force is the curator holding the modifier: he has been shown the refusal and
// asked for it anyway, exactly as ACE's Zeus module treats Shift.
if (_force) exitWith {""};

if ((getTerrainHeightASL _pos) < 0) exitWith {LLSTRING(ReasonWater)};

if (!([_pos] call FUNC(surfaceDiggable))) exitWith {LLSTRING(ReasonSurface)};

if (isOnRoad _pos) exitWith {LLSTRING(ReasonRoad)};

// Trees, rocks and walls baked into the terrain. These cannot be moved or deleted,
// so a trench through one would leave the trunk standing in the floor.
if ((nearestTerrainObjects [_pos, [], _radius, false, true]) isNotEqualTo []) exitWith {
    LLSTRING(ReasonTerrainObject)
};

// Mission-placed objects, including anything a curator built here earlier. Logics
// are skipped: curator modules, the Zeus camera and every group's centre sit at
// map positions and are not physically in the way of anything.
if (((nearestObjects [_pos, ["All"], _radius, true]) select {!(_x isKindOf "Logic")}) isNotEqualTo []) exitWith {
    LLSTRING(ReasonObject)
};

""
