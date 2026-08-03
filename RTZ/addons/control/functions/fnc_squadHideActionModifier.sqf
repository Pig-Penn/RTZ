#include "script_component.hpp"
/*
 * Author: Maxim
 * CfgContext modifierFunction for the squad hide/freeze toggle (see
 * CfgContext.hpp). Sets the action's label, icon and tint to reflect the
 * first selected group's state:
 *   under Dynamic Simulation → blue   "Disable Dynamic Simulation"
 *   visible                  → orange "Disable Simulation"
 *   hidden                   → green  "Enable Simulation"
 *
 * Dynamic Simulation is only ever turned on by mission placement in the
 * editor, never at runtime, so a group either starts under it or never is —
 * this branch is checked first and, once cleared, never resurfaces.
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

private _grp = _grps select 0;

if (dynamicSimulationEnabled _grp && {!(_grp getVariable [QGVAR(dynSimDisabled), false])}) exitWith {
    _action set [ACTION_INDEX_DISPLAYNAME, LLSTRING(ActionDisableDynamicSimulation)];
    _action set [ACTION_INDEX_ICON, ICON_SHOW];
    _action set [ACTION_INDEX_ICONCOLOR, COLOR_DYNSIM];
};

private _hidden = _grp getVariable [QGVAR(squadHidden), false];
if (_hidden) then {
    _action set [ACTION_INDEX_DISPLAYNAME, LLSTRING(ActionEnableSimulation)];
    _action set [ACTION_INDEX_ICON, ICON_SHOW];
    _action set [ACTION_INDEX_ICONCOLOR, COLOR_SHOW];   // green — currently hidden, will restore
} else {
    _action set [ACTION_INDEX_DISPLAYNAME, LLSTRING(ActionDisableSimulation)];
    _action set [ACTION_INDEX_ICON, ICON_HIDE];
    _action set [ACTION_INDEX_ICONCOLOR, COLOR_HIDE];   // orange — will hide & freeze
};
