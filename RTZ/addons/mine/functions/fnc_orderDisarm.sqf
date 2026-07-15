#include "script_component.hpp"
/*
 * Author: Maxim
 * Orders every selected demine-capable group to sweep the area around the
 * context menu position for mines. The order runs where each group is local.
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

params ["_position", "_objects"];

private _groups = _objects call FUNC(getDeminers);
if (_groups isEqualTo []) exitWith {};

private _pos = ASLToAGL _position;

{
    [QGVAR(disarm), [_x, _pos, GVAR(clearHidden)], leader _x] call CBA_fnc_targetEvent;
} forEach _groups;
