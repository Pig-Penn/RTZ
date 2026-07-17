#include "script_component.hpp"
/*
 * rtz_fnc_dismountActionModifier
 *
 * ZEN context-menu modifierFunction for the dismount toggle action.
 * Mutates the action's displayName (index 1), icon path (index 2), and
 * iconColor (index 3) to reflect the live vehicle state — amber padlock
 * "Forbid Dismount" while vanilla; cyan "Allow Dismount" once locked.
 *
 * Parameters (passed by ZEN as [_action, ACTION_PARAMS]):
 *   0: Array — the action array (mutated in place)
 *   1: Array — ZEN action params: [_position, _objects, _groups, _waypoints, _markers, _hoveredEntity, _args]
 */
params ["_action", "_actionParams"];
_actionParams params ["", "_objects", "", "", "", "_hoveredEntity"];
private _vehs = [_objects + [_hoveredEntity]] call EFUNC(common,collectVehicles);
if (_vehs isEqualTo []) exitWith {};
if ((_vehs select 0) getVariable [QGVAR(unloadInCombat), true]) then {
    _action set [ACTION_INDEX_DISPLAYNAME, "Forbid Dismount"];
    _action set [ACTION_INDEX_ICON, ICON_LOCKED];
    _action set [ACTION_INDEX_ICONCOLOR, COLOR_LOCKED];     // amber — will lock crew in
} else {
    _action set [ACTION_INDEX_DISPLAYNAME, "Allow Dismount"];
    _action set [ACTION_INDEX_ICON, ICON_UNLOCKED];
    _action set [ACTION_INDEX_ICONCOLOR, COLOR_UNLOCKED];   // cyan — currently locked, will release
};
