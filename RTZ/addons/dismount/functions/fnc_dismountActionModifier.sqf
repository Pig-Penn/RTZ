#include "script_component.hpp"
/*
 * rtz_fnc_dismountActionModifier
 *
 * CfgContext modifierFunction for the dismount toggle (see CfgContext.hpp).
 * Mutates the action's displayName (index 1), icon path (index 2), and
 * iconColor (index 3) to reflect the live vehicle state — amber padlock
 * "Forbid Dismount" while vanilla; cyan "Allow Dismount" once locked.
 *
 * Parameters:
 *   0: Array — the action array (mutated in place)
 *   1: Array — selection objects + hovered entity (pre-combined by the caller)
 */
params ["_action", "_objects"];
private _vehs = [_objects] call EFUNC(common,collectVehicles);
if (_vehs isEqualTo []) exitWith {};
if ((_vehs select 0) getVariable [QGVAR(unloadInCombat), true]) then {
    _action set [ACTION_INDEX_DISPLAYNAME, LLSTRING(ActionForbidDismount)];
    _action set [ACTION_INDEX_ICON, ICON_LOCKED];
    _action set [ACTION_INDEX_ICONCOLOR, COLOR_LOCKED];     // amber — will lock crew in
} else {
    _action set [ACTION_INDEX_DISPLAYNAME, LLSTRING(ActionAllowDismount)];
    _action set [ACTION_INDEX_ICON, ICON_UNLOCKED];
    _action set [ACTION_INDEX_ICONCOLOR, COLOR_UNLOCKED];   // cyan — currently locked, will release
};
