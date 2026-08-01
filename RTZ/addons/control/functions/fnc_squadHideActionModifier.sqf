#include "script_component.hpp"
/*
 * Author: Maxim
 * CfgContext modifierFunction for the squad hide/freeze toggle (see
 * CfgContext.hpp). Sets the action's label, icon and tint to reflect whether
 * the first selected group is currently hidden:
 *   visible → orange "Disable Simulation"
 *   hidden  → green  "Enable Simulation"
 *
 * Arguments:
 * 0: The action array (mutated in place) <ARRAY>
 * 1: Selection objects + hovered entity (pre-combined by the caller) <ARRAY>
 *
 * Return Value:
 * None
 *
 * Example:
 * [_action, _objects] call rtz_control_fnc_squadHideActionModifier
 *
 * Public: No
 */

params ["_action", "_objects"];

private _grps = [_objects] call EFUNC(common,collectSquads);
if (_grps isEqualTo []) exitWith {};

private _hidden = (_grps select 0) getVariable [QGVAR(squadHidden), false];
if (_hidden) then {
    _action set [ACTION_INDEX_DISPLAYNAME, LLSTRING(ActionEnableSimulation)];
    _action set [ACTION_INDEX_ICON, ICON_SHOW];
    _action set [ACTION_INDEX_ICONCOLOR, COLOR_SHOW];   // green — currently hidden, will restore
} else {
    _action set [ACTION_INDEX_DISPLAYNAME, LLSTRING(ActionDisableSimulation)];
    _action set [ACTION_INDEX_ICON, ICON_HIDE];
    _action set [ACTION_INDEX_ICONCOLOR, COLOR_HIDE];   // orange — will hide & freeze
};
