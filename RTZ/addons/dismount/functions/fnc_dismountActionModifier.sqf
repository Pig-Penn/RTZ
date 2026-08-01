#include "script_component.hpp"
/*
 * Author: Maxim
 * CfgContext modifierFunction for the dismount toggle (see CfgContext.hpp).
 * Mutates the action's displayName (index 1), icon path (index 2), and
 * iconColor (index 3) to reflect the live vehicle state — amber padlock
 * "Forbid Dismount" while vanilla; cyan "Allow Dismount" once locked.
 *
 * Mirrors FUNC(toggleUnloadInCombat)'s any-unlocked-wins rule over the same
 * resolved set, so the label is a promise about what the click will do rather
 * than a report on one arbitrary vehicle.
 *
 * Arguments:
 * 0: The action array (mutated in place) <ARRAY>
 * 1: Selection objects + hovered entity (pre-combined by the caller) <ARRAY>
 *
 * Return Value:
 * None
 *
 * Example:
 * [_action, _objects] call rtz_dismount_fnc_dismountActionModifier
 *
 * Public: No
 */
params ["_action", "_objects"];
private _vehs = [_objects] call FUNC(collectDismountVehicles);
if (_vehs isEqualTo []) exitWith {};
if ((_vehs findIf {_x getVariable [QGVAR(unloadInCombat), true]}) != -1) then {
    _action set [ACTION_INDEX_DISPLAYNAME, LLSTRING(ActionForbidDismount)];
    _action set [ACTION_INDEX_ICON, ICON_LOCKED];
    _action set [ACTION_INDEX_ICONCOLOR, COLOR_LOCKED];     // amber — will lock crew in
} else {
    _action set [ACTION_INDEX_DISPLAYNAME, LLSTRING(ActionAllowDismount)];
    _action set [ACTION_INDEX_ICON, ICON_UNLOCKED];
    _action set [ACTION_INDEX_ICONCOLOR, COLOR_UNLOCKED];   // cyan — currently locked, will release
};
