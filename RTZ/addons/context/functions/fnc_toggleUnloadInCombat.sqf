#include "script_component.hpp"
/*
 * rtz_fnc_toggleUnloadInCombat
 *
 * Reads the current allow-state from the first selected vehicle, inverts it,
 * and applies it to all selected vehicles. Reports the new state as a toast.
 *
 * Parameters:
 *   0: Array — objects from curatorSelected or a keybind handler
 */
params ["_objects"];
private _vehicles = [_objects] call FUNC(collectVehicles);
if (_vehicles isEqualTo []) exitWith {
    ["Select a vehicle to lock its crew in"] call zen_common_fnc_showMessage;
};
private _newAllow = !((_vehicles select 0) getVariable [QGVAR(unloadInCombat), true]);
[_vehicles, _newAllow] call FUNC(setUnloadInCombat);

private _msg = ["Dismount forbidden", "Dismount allowed"] select _newAllow;
if (count _vehicles > 1) then { _msg = format ["%1  x%2", _msg, count _vehicles]; };
[_msg] call zen_common_fnc_showMessage;
