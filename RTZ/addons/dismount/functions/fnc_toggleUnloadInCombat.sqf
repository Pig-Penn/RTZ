#include "script_component.hpp"
/*
 * Author: Maxim
 * Reads the current allow-state from the first selected vehicle, inverts it,
 * and applies it to all selected vehicles. Reports the new state as a toast.
 *
 * Arguments:
 * 0: Objects from curatorSelected or a keybind handler <ARRAY>
 *
 * Return Value:
 * None
 *
 * Example:
 * [_objects] call rtz_dismount_fnc_toggleUnloadInCombat
 *
 * Public: No
 */

params ["_objects"];

private _vehicles = [_objects] call EFUNC(common,collectVehicles);
if (_vehicles isEqualTo []) exitWith {
    [LLSTRING(MsgNoVehicleSelected)] call zen_common_fnc_showMessage;
};

private _newAllow = !((_vehicles select 0) getVariable [QGVAR(unloadInCombat), true]);
[_vehicles, _newAllow] call FUNC(setUnloadInCombat);

private _msg = [LLSTRING(MsgDismountForbidden), LLSTRING(MsgDismountAllowed)] select _newAllow;
if (count _vehicles > 1) then { _msg = format ["%1  x%2", _msg, count _vehicles]; };
[_msg] call zen_common_fnc_showMessage;
