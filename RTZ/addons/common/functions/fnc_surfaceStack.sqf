#include "script_component.hpp"
/*
 * Author: Maxim
 * Every mostly-flat surface in the vertical column at a world x/y, HIGHEST
 * FIRST: the roof, then each interior floor below it, then the terrain under
 * them all. The answer to "what could something stand on here", with the
 * choosing left to the caller.
 *
 * Callers pick out of the stack rather than being handed one answer, because
 * "which surface" is a question only the caller can answer. EFUNC(place,
 * seedPositions) wants the entry NEAREST the height the curator is aiming at,
 * so a squad seeded around an interior cursor lands on that floor instead of
 * being lifted onto the roof. Something dropping supplies would want the first
 * entry. The old inlined version of this trace answered "highest" for everyone
 * and that is exactly why the curator teleport could never place indoors.
 *
 * The ray runs DOWNWARD, from SURFACE_PROBE_UP metres above terrain to
 * SURFACE_PROBE_DOWN below it, so hits arrive ordered top to bottom — sorted by
 * distance from the begin position, which is the high end.
 *
 * There is deliberately no `break` in the loop below and so no exposure to the
 * `exitWith`-in-a-forEach trap (docs/Knowledge Base/Gotchas.md §2) that bit both
 * sites this code was extracted from. Collecting every hit is the whole point;
 * nothing short-circuits, so there is nothing to get wrong.
 *
 * Never returns an empty array: with no usable hit at all (over water, or a
 * column that is nothing but steep faces) it answers with the bare terrain
 * point, which is what a ground snap would have produced anyway.
 *
 * Arguments:
 * 0: World X <NUMBER>
 * 1: World Y <NUMBER>
 * 2: Object the trace ignores <OBJECT> (default: objNull)
 *
 * Return Value:
 * Surface positions (ASL), highest first, never empty <ARRAY>
 *
 * Example:
 * private _floors = [_x, _y, _unit] call rtz_common_fnc_surfaceStack
 *
 * Public: No
 */

// NOT named _x: this runs a forEach below, whose magic _x would shadow it.
params ["_px", "_py", ["_ignoreObj", objNull]];

private _terrainASL = getTerrainHeightASL [_px, _py];
private _surfaces = [];

{
    _x params ["_intersectPos", "_surfaceNormal"];

    if (_surfaceNormal vectorDotProduct [0, 0, 1] > SURFACE_FLAT_MIN) then {
        _surfaces pushBack _intersectPos;
    };
} forEach lineIntersectsSurfaces [
    [_px, _py, _terrainASL + SURFACE_PROBE_UP],
    [_px, _py, _terrainASL - SURFACE_PROBE_DOWN],
    _ignoreObj, objNull, true, SURFACE_PROBE_HITS
];

if (_surfaces isEqualTo []) exitWith {[[_px, _py, _terrainASL]]};

_surfaces
