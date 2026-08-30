#include "script_component.hpp"
/*
 * Author: Maxim
 * Per-frame body of an open placement session: drives the ghost being dragged to
 * the cursor, and ends the session if Zeus goes away underneath it.
 *
 * That is all it does. Everything else a session shows — hover, range, labels —
 * is resolved by FUNC(drawGhosts), which is already walking every ghost with the
 * camera basis in hand; duplicating that walk here would be a second per-frame
 * pass over the same array to compute things the first one already has.
 *
 * With nothing grabbed this costs one array read and one comparison per frame.
 *
 * DRAGGING IS WHAT PUTS UNITS INDOORS. The dragged ghost is snapped to the
 * nearest mostly-flat surface along the ray from the curator camera to the
 * cursor (EFUNC(common,cursorSurface)). With the camera outside a building that
 * is the roof; fly it into the room and it is that room's floor. The curator
 * picks the storey by moving the camera, so nothing here needs to know what a
 * building is, count floors, or snap to anything.
 *
 * Arguments:
 * 0: PFH arguments (unused) <ARRAY>
 * 1: PFH id (unused — FUNC(endPlacement) removes it by GVAR(placePfh)) <NUMBER>
 *
 * Return Value:
 * None
 *
 * Example:
 * GVAR(placePfh) = [LINKFUNC(placeTick), 0, []] call CBA_fnc_addPerFrameHandler
 *
 * Public: No
 */

// Zeus closed out from under the session — its own keybind, player death, remote
// control. CANCEL, never commit: the curator did not ask for these placements to
// happen, and a session that silently teleported a squad on the way out of Zeus
// would be the worst possible reading of an ambiguous exit. Detected here rather
// than in a handler because the display going away takes its handlers with it.
// Matches rtz_path.
if (isNull (findDisplay IDD_RSCDISPLAYCURATOR)) exitWith {
    [] call FUNC(endPlacement);
};

private _grabbed = GVAR(grabbed);
if (_grabbed < 0) exitWith {};

// The Zeus map covers the 3D view, so the cursor ray points into a scene the
// curator cannot see. Hold the ghost where it is until the map is closed rather
// than dragging it somewhere blind. The grab is deliberately NOT released: the
// curator gets their drag back, in progress, on the frame the map goes away.
if (visibleMap) exitWith {};

private _ghost = GVAR(ghosts) param [_grabbed, []];
if (_ghost isEqualTo []) exitWith {GVAR(grabbed) = -1};

_ghost params ["", "_helper", "_model"];
if (isNull _helper) exitWith {GVAR(grabbed) = -1};

// Both ignore slots go to this ghost's own helper and model. Each would
// otherwise present a mostly-flat face to the trace and the ghost would climb
// itself — the same two-slot problem EFUNC(common,placementPreview) documents
// for ZEN's ghost and its own.
([_helper, _model] call EFUNC(common,cursorSurface)) params ["_posASL", "_vectorUp"];

_helper setPosASL _posASL;
_helper setVectorUp _vectorUp;
