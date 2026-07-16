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
    _action set [1, "Forbid Dismount"];
    _action set [2, "\a3\modules_f\data\iconlock_ca.paa"];
    _action set [3, [1.00, 0.78, 0.22, 1]];   // amber — will lock crew in
} else {
    _action set [1, "Allow Dismount"];
    _action set [2, "\a3\modules_f\data\iconunlock_ca.paa"];
    _action set [3, [0.40, 0.80, 1.00, 1]];   // cyan — currently locked, will release
};
