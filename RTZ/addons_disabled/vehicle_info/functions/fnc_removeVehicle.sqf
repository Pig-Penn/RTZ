#include "script_component.hpp"
/*
 * Author: Maxim
 * Stops tracking a vehicle.
 *
 * Arguments:
 * 0: Vehicle <OBJECT>
 *
 * Return Value:
 * None
 *
 * Example:
 * [_vehicle] call rtz_vehicle_info_fnc_removeVehicle
 *
 * Public: No
 */

params [["_vehicle", objNull, [objNull]]];

_vehicle setVariable [QGVAR(tracked), nil];
_vehicle setVariable [QGVAR(data), nil];

private _index = GVAR(vehicles) find _vehicle;
if (_index != -1) then {
    GVAR(vehicles) deleteAt _index;
};

if (GVAR(vehicles) isEqualTo []) then {
    call FUNC(stop);
};
