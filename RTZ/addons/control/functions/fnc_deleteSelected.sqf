#include "script_component.hpp"
/*
 * Author: Maxim
 * Keybind entry point for the delete action: runs FUNC(deleteObjects) on the
 * current Zeus selection, so the shortcut and the context menu entry share one
 * code path (and the same player/curator-module protection).
 *
 * The key is swallowed whenever the Zeus interface is up and the feature is
 * enabled, even with nothing selected. Letting it through would hand the press
 * to Zeus's own Delete action, which deletes with a point refund — exactly what
 * this feature exists to avoid.
 *
 * Arguments:
 * None
 *
 * Return Value:
 * Key handled <BOOL>
 *
 * Example:
 * call rtz_control_fnc_deleteSelected
 *
 * Public: No
 */

if (isNull curatorCamera) exitWith { false };

// Typing in the create-tree search box must keep producing text
if (GETMVAR(RscDisplayCurator_search,false)) exitWith { false };

if (!GVAR(enableDelete)) exitWith { false };

curatorSelected params ["_objects", "_groups"];
[_objects, _groups, objNull] call FUNC(deleteObjects);

true // handled
