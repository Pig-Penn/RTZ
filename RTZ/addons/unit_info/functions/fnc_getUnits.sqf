#include "script_component.hpp"
/*
 * Author: Maxim
 * Returns all infantry units from the given objects, expanding vehicles to their crews.
 *
 * Arguments:
 * 0: Objects <ARRAY>
 *
 * Return Value:
 * Units <ARRAY>
 *
 * Example:
 * [_objects] call rtz_unit_info_fnc_getUnits
 *
 * Public: No
 */

params [["_objects", [], [[]]]];

private _units = [];

{
    if (_x isKindOf "CAManBase") then {
        _units pushBackUnique _x;
    } else {
        {
            _units pushBackUnique _x;
        } forEach (crew _x);
    };
} forEach _objects;

_units
