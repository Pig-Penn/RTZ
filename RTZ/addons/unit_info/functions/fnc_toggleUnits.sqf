#include "script_component.hpp"
/*
 * Author: Maxim
 * Toggles the unit info display for the given objects.
 * Enables the display if any unit is untracked, otherwise disables it for all.
 *
 * Arguments:
 * 0: Objects <ARRAY>
 *
 * Return Value:
 * None
 *
 * Example:
 * [_objects] call rtz_unit_info_fnc_toggleUnits
 *
 * Public: No
 */

params [["_objects", [], [[]]]];

private _units = _objects call FUNC(getUnits);
if (_units isEqualTo []) exitWith {};

private _enable = _units findIf {!(_x getVariable [QGVAR(tracked), false])} != -1;

{
    if (_enable) then {
        _x call FUNC(addUnit);
    } else {
        _x call FUNC(removeUnit);
    };
} forEach _units;
