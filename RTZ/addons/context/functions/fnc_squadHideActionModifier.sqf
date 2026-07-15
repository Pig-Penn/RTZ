#include "script_component.hpp"
/*
 * rtz_fnc_squadHideActionModifier
 *
 * ZEN context-menu modifierFunction for the squad hide/freeze toggle. Sets the
 * action's label (index 1) and tint (index 3) to reflect whether the first
 * selected group is currently hidden:
 *   visible → orange "Enable Simulation"
 *   hidden  → green  "Disable Simulation"
 *
 * Parameters (passed by ZEN as [_action, ACTION_PARAMS]):
 *   0: Array — the action array (mutated in place)
 *   1: Array — [_position, _objects, _groups, _waypoints, _markers, _hoveredEntity, _args]
 */

params ["_action", "_actionParams"];
_actionParams params ["", "_objects", "", "", "", "_hoveredEntity"];

private _grps = [_objects + [_hoveredEntity]] call FUNC(collectSquads);
if (_grps isEqualTo []) exitWith {};

private _hidden = (_grps select 0) getVariable [QGVAR(squadHidden), false];
if (_hidden) then {
    _action set [1, "Enable Simulation"];
    _action set [2, "\x\rtz\addons\context\ui\play_ca.paa"];
    _action set [3, [0.40, 1.00, 0.40, 1]];   // green — currently hidden, will restore
} else {
    _action set [1, "Disable Simulation"];
    _action set [2, "\x\rtz\addons\context\ui\pause_ca.paa"];
    _action set [3, [1.00, 0.60, 0.20, 1]];   // orange — will hide & freeze
};
