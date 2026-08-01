#include "script_component.hpp"
/*
 * Author: Maxim
 * Draws an icon on each cached spotted mine on the Zeus map. The cache is already
 * a flat list of validated positions (FUNC(refreshMines)), and the handler is only
 * attached while GVAR(markMap) is on (FUNC(start)), so this is just the loop.
 *
 * Arguments:
 * 0: Zeus Map Control <CONTROL>
 *
 * Return Value:
 * None
 *
 * Example:
 * [_ctrlMap] call rtz_mine_fnc_drawMap
 *
 * Public: No
 */

params ["_ctrlMap"];

private _mines = GVAR(mines);
if (_mines isEqualTo []) exitWith {};

private _icon = GVAR(icon);

{
    _ctrlMap drawIcon [_icon, COLOR_MINE, _x, ICON_SIZE_MAP, ICON_SIZE_MAP, 0];
} forEach _mines;
