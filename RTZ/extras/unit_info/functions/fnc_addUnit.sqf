#include "script_component.hpp"
/*
 * Author: Maxim
 * Starts tracking a unit and caches its static draw data.
 *
 * Arguments:
 * 0: Unit <OBJECT>
 *
 * Return Value:
 * None
 *
 * Example:
 * [_unit] call rtz_unit_info_fnc_addUnit
 *
 * Public: No
 */

params [["_unit", objNull, [objNull]]];

if (isNull _unit || {_unit getVariable [QGVAR(tracked), false]}) exitWith {};

// Cache values that are static or expensive to compute every frame
// (name returns "Error: No unit" for dead units, so it must be cached now)
private _height = ((boundingBoxReal _unit) select 1 select 2) + HEIGHT_OFFSET;
private _name = name _unit;
private _sideColor = ([side group _unit] call BIS_fnc_sideColor) + [1];
_sideColor resize 4;

_unit setVariable [QGVAR(tracked), true];
_unit setVariable [QGVAR(data), [_height, _name, _sideColor]];

GVAR(units) pushBack _unit;

call FUNC(start);
