#include "script_component.hpp"
/*
 * rtz_control_fnc_squadHideActionModifier
 *
 * CfgContext modifierFunction for the squad hide/freeze toggle (see
 * CfgContext.hpp). Sets the action's label, icon and tint to reflect whether
 * the first selected group is currently hidden:
 *   visible → orange "Disable Simulation"
 *   hidden  → green  "Enable Simulation"
 *
 * Parameters:
 *   0: Array  — the action array (mutated in place)
 *   1: Array  — selection objects + hovered entity (pre-combined by the caller)
 */

params ["_action", "_objects"];

private _grps = [_objects] call EFUNC(common,collectSquads);
if (_grps isEqualTo []) exitWith {};

private _hidden = (_grps select 0) getVariable [QGVAR(squadHidden), false];
if (_hidden) then {
    _action set [1, LLSTRING(ActionEnableSimulation)];
    _action set [2, ICON_SHOW];
    _action set [3, COLOR_SHOW];   // green — currently hidden, will restore
} else {
    _action set [1, LLSTRING(ActionDisableSimulation)];
    _action set [2, ICON_HIDE];
    _action set [3, COLOR_HIDE];   // orange — will hide & freeze
};
