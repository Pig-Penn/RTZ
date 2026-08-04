#include "script_component.hpp"
/*
 * Author: Maxim
 * Whether a path may be extended from one position to another: is the segment
 * between them clear, and is the far end somewhere the subject can actually be.
 *
 * Clearance forgives only things that MOVE — men and vehicles wander off the
 * line long before anything drives down it, so a squad standing in a doorway
 * must not veto a path through it. It deliberately does NOT try to recognise
 * doors, which is where Wargame spends a hand-rolled nearest-door search per
 * blocked sample. A traced line that hits a building is exactly the case the
 * calculatePath fallback exists for, and the engine's own pathfinder already
 * knows which doors open.
 *
 * Ground contact costs nothing in the ordinary case. The cursor position arrives
 * already resolved onto a surface, and the caller's incline gate rejects cliff
 * faces, so the only question left is water: a boat path must be on it, a land
 * path must not — unless something solid is spanning it, which is a bridge or a
 * pier, and is the one case that pays for a ray.
 *
 * Arguments:
 * 0: Segment start, ASL <ARRAY>
 * 1: Segment end, ASL <ARRAY>
 * 2: Hull being pathed, ignored by the line test <OBJECT>
 * 3: Path kind, one of KIND_* <NUMBER>
 * 4: Drawing profile for that kind <ARRAY>
 *
 * Return Value:
 * The path may be extended to the end position <BOOL>
 *
 * Example:
 * if ([_head, _target, _hull, _kind, _profile] call rtz_path_fnc_validatePoint) then {...};
 *
 * Public: No
 */

params ["_from", "_to", "_hull", "_kind", "_profile"];

private _clearHeight = _profile select PROF_CLEAR_HEIGHT;
private _lift = [0, 0, _clearHeight];

// One hit is enough to answer the question, so ask for one.
private _hits = lineIntersectsSurfaces [
    _from vectorAdd _lift,
    _to vectorAdd _lift,
    _hull,
    objNull,
    true,
    1,
    _profile select PROF_LOD_NEAR,
    _profile select PROF_LOD_FAR,
    true
];

if (_hits isNotEqualTo []) then {
    private _blocker = _hits select 0 select 2;

    // Anything that can move out of the way is not an obstacle to a plan. Note
    // AllVehicles covers men as well, but the two are listed apart because the
    // reasoning differs: a man steps aside, a vehicle is driven away.
    private _movable = _blocker isKindOf "CAManBase" || {_blocker isKindOf "AllVehicles"};
    if (!_movable) exitWith {false};
};

// Aircraft need no surface under them at all — altitude is the point.
if (_kind == KIND_AIR) exitWith {true};

private _overWater = surfaceIsWater _to;

if (_kind == KIND_BOAT) exitWith {_overWater};

if (!_overWater) exitWith {true};

// Over water and not a boat: only a solid deck spanning it will do. Cast
// downward THROUGH the point, so a bridge surface above or below the resolved
// cursor position is found either way.
(lineIntersectsSurfaces [
    _to vectorAdd [0, 0, BRIDGE_PROBE],
    _to vectorAdd [0, 0, -BRIDGE_PROBE],
    _hull,
    objNull,
    true,
    1,
    "GEOM",
    "FIRE",
    true
]) isNotEqualTo []
