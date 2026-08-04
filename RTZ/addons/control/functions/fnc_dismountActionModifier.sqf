#include "script_component.hpp"
/*
 * Author: Maxim
 * CfgContext modifierFunction for the dismount toggle (see CfgContext.hpp).
 * Mutates the action's displayName, icon path and iconColor to reflect the live
 * vehicle state — amber padlock "Forbid Dismount" while vanilla; cyan "Allow
 * Dismount" once locked.
 *
 * Mirrors FUNC(dismountToggle)'s any-unlocked-wins rule over the same resolved
 * set, so the label is a promise about what the click will do rather than a
 * report on one arbitrary vehicle.
 *
 * Arguments:
 * 0: The action array (mutated in place) <ARRAY>
 * 1: Selection objects + hovered entity (pre-combined by the caller) <ARRAY>
 *
 * Return Value:
 * None
 *
 * Example:
 * [_action, _objects] call rtz_control_fnc_dismountActionModifier
 *
 * Public: No
 */

params ["_action", "_objects"];

private _vehs = [_objects] call FUNC(collectDismountVehicles);
if (_vehs isEqualTo []) exitWith {};

if ((_vehs findIf {_x getVariable [QGVAR(dismountAllowed), true]}) != -1) then {
    // amber — will lock crew in
    SET_ACTION(_action,LLSTRING(ActionForbidDismount),ICON_LOCKED,COLOR_LOCKED);
} else {
    // cyan — currently locked, will release
    SET_ACTION(_action,LLSTRING(ActionAllowDismount),ICON_UNLOCKED,COLOR_UNLOCKED);
};
