#include "script_component.hpp"
/*
 * Author: Maxim
 * Keybind handler: teleports the local Zeus camera to the world position
 * under the map cursor. The engine's native middle-click map teleport is
 * blocked whenever the curator has an editing area (the camera is clamped to
 * the editing bounds), so this replicates it, bypassing the restriction.
 *
 * Bound to a CBA keybind (default "F") rather than plain MMB because the Zeus
 * map control consumes the raw middle-mouse press as its own (blocked)
 * teleport action before any script mouse handler sees it — left/right clicks
 * fire MouseButtonDown on the map control, the middle button fires nothing.
 *
 * Locality: pure client / UI. curatorCamera is the local Zeus camera; nothing
 * is sent to the server. Runs only on the key press; no per-frame cost.
 *
 * Arguments:
 * None
 *
 * Return Value:
 * Press was handled (consumed) <BOOL>
 *
 * Example:
 * call rtz_common_fnc_curatorMapTeleport
 *
 * Public: No
 */

// Non-null only while this machine's Zeus interface is open
if (isNull curatorCamera) exitWith {false};
if (!visibleMap) exitWith {false};

// Typing in the Zeus search box (ZEN sets this flag): don't hijack the keystroke
if (GETMVAR(RscDisplayCurator_search,false)) exitWith {false};

private _ctrlMap = findDisplay IDD_RSCDISPLAYCURATOR displayCtrl IDC_RSCDISPLAYCURATOR_MAINMAP;
if (isNull _ctrlMap) exitWith {false};

// Cursor position on the map → world (ctrlMapScreenToWorld extrapolates, so
// it always yields a position, even with the cursor off the map's edge)
private _worldPos = _ctrlMap ctrlMapScreenToWorld getMousePosition;

// Preserve the camera's height above terrain so the zoom level is kept
// across the jump (matches the feel of the native middle-click teleport)
private _camera = curatorCamera;
_camera setPosATL [_worldPos select 0, _worldPos select 1, (getPosATL _camera) select 2];

true
