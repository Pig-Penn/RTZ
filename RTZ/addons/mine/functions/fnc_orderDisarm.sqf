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

if (!GVAR(enabled)) exitWith {};

private _groups = [_objects] call FUNC(getDeminers);
if (_groups isEqualTo []) exitWith {};

private _pos = ASLToAGL _position;
private _clearHidden = GVAR(clearHidden);

{
    [QGVAR(disarm), [_x, _pos, _clearHidden], leader _x] call CBA_fnc_targetEvent;
} forEach _groups;

[LLSTRING(MsgDemining), count _groups] call EFUNC(common,showCountMessage);
