#include "script_component.hpp"
/*
 * Author: Maxim
 * Orders the best suited selected explosive specialist to disarm
 * the spotted mine nearest to the context menu position.
 *
 * Arguments:
 * 0: Context Position ASL <ARRAY>
 * 1: Selected Objects <ARRAY>
 *
 * Return Value:
 * None
 *
 * Example:
 * [_position, _objects] call rtz_mine_fnc_orderDisarm
 *
 * Public: No
 */

(_this call FUNC(findDisarmTarget)) params [["_unit", objNull], ["_mine", objNull]];

if (isNull _unit) exitWith {};

[QGVAR(disarm), [_unit, _mine], _unit] call CBA_fnc_targetEvent;
