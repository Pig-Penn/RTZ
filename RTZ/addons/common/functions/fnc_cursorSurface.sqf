#include "script_component.hpp"
/*
 * Author: Maxim
 * The nearest mostly-flat surface along the ray from the curator camera to the
 * cursor — "what is the curator pointing at", ready to stand something on.
 *
 * NEAREST, from the CAMERA, is what makes indoor placement work at all. With the
 * camera outside a building the first flat hit is the roof, which is the honest
 * answer to what the cursor is over. Fly the camera into the room and the first
 * flat hit is that room's floor. The curator chooses the storey by moving the
 * camera, so nothing here has to guess at building interiors, count floors, or
 * know what a building is.
 *
 * Contrast FUNC(surfaceStack), which probes a vertical column at an arbitrary
 * x/y and hands back every floor in it. That one answers "what is under this
 * point"; this one answers "what is the curator looking at". Both were inlined
 * copies before, both carrying the same hazard note, and neither could be called
 * from the other's caller.
 *
 * Extracted from FUNC(placementPreview), which still calls it — the ghost that
 * rides the cursor and a placement session's dragged handle need exactly the
 * same answer.
 *
 * Two ignore slots because that is all lineIntersectsSurfaces has, and a caller
 * dragging a ghost needs both of them for its own helper and model: each would
 * otherwise present a flat face to the trace and the ghost would climb itself.
 * See FUNC(placementPreview)'s entry guard for what happens when two ghosts
 * compete for the same two slots.
 *
 * Falls back to the terrain point under the cursor with its own surface normal
 * when the ray finds nothing flat, so the return is always usable.
 *
 * Arguments:
 * 0: First object the trace ignores <OBJECT> (default: objNull)
 * 1: Second object the trace ignores <OBJECT> (default: objNull)
 *
 * Return Value:
 * 0: Surface position (ASL) <ARRAY>
 * 1: Surface normal, for setVectorUp <ARRAY>
 *
 * Example:
 * ([_helper, _ghost] call rtz_common_fnc_cursorSurface) params ["_posASL", "_up"]
 *
 * Public: No
 */

params [["_ignoreOne", objNull, [objNull]], ["_ignoreTwo", objNull, [objNull]]];

private _position = AGLToASL screenToWorld getMousePosition;
private _vectorUp = surfaceNormal _position;

// `break`, not `exitWith`. Hits come back sorted by distance from the BEGIN
// position — the curator camera — so the first mostly-flat surface is the
// NEAREST one, i.e. the roof (or floor) the cursor is actually over. This was an
// `exitWith`, which inside a forEach unwinds only the current ITERATION (it is
// continue, not break — docs/Knowledge Base/Gotchas.md §2), so every later,
// FURTHER surface overwrote the result and the ghost snapped through the
// building to the ground beneath it.
{
    _x params ["_intersectPos", "_surfaceNormal"];

    if (_surfaceNormal vectorDotProduct [0, 0, 1] > SURFACE_FLAT_MIN) then {
        _position = _intersectPos;
        _vectorUp = _surfaceNormal;
        break;
    };
} forEach lineIntersectsSurfaces [
    getPosASL curatorCamera, _position,
    _ignoreOne, _ignoreTwo, true, SURFACE_CURSOR_HITS
];

[_position, _vectorUp]
