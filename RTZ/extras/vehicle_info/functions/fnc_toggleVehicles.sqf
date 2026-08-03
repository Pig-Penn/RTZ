#include "script_component.hpp"
/*
 * Author: Maxim
 * Toggles the vehicle info display for the given objects.
 * Enables the display if any vehicle is untracked, otherwise disables it for all.
 *
 * Arguments:
 * 0: Objects <ARRAY>
 *
 * Return Value:
 * None
 *
 * Example:
 * [_objects] call rtz_vehicle_info_fnc_toggleVehicles
 *
 * Public: No
 */

params [["_objects", [], [[]]]];

private _vehicles = [_objects] call FUNC(getVehicles);
if (_vehicles isEqualTo []) exitWith {};

private _enable = _vehicles findIf {!(_x getVariable [QGVAR(tracked), false])} != -1;

{
    if (_enable) then {
        _x call FUNC(addVehicle);
    } else {
        _x call FUNC(removeVehicle);
    };
} forEach _vehicles;
