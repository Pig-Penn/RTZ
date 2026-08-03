#include "script_component.hpp"
/*
 * Author: Maxim
 * Returns all vehicles from the given objects, resolving crew members to their vehicles.
 *
 * Arguments:
 * 0: Objects <ARRAY>
 *
 * Return Value:
 * Vehicles <ARRAY>
 *
 * Example:
 * [_objects] call rtz_vehicle_info_fnc_getVehicles
 *
 * Public: No
 */

params [["_objects", [], [[]]]];

private _vehicles = [];

{
    if (_x isKindOf "CAManBase") then {
        private _vehicle = objectParent _x;
        if (!isNull _vehicle) then {
            _vehicles pushBackUnique _vehicle;
        };
    } else {
        if (_x isKindOf "AllVehicles") then {
            _vehicles pushBackUnique _x;
        };
    };
} forEach _objects;

_vehicles
