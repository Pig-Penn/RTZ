#include "script_component.hpp"
/*
 * Author: Maxim
 * Stops tracking a unit.
 *
 * Arguments:
 * 0: Unit <OBJECT>
 *
 * Return Value:
 * None
 *
 * Example:
 * [_unit] call rtz_unit_info_fnc_removeUnit
 *
 * Public: No
 */

params [["_unit", objNull, [objNull]]];

_unit setVariable [QGVAR(tracked), nil];
_unit setVariable [QGVAR(data), nil];

private _index = GVAR(units) find _unit;
if (_index != -1) then {
    GVAR(units) deleteAt _index;
};

if (GVAR(units) isEqualTo []) then {
    call FUNC(stop);
};
