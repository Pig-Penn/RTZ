#include "script_component.hpp"
/*
 * Author: Maxim
 * Whether a clear mines order is possible: at least one selected group can
 * clear mines and there is an active mine near the context menu position.
 * Drives the visibility of the context menu action.
 *
 * Arguments:
 * 0: Context Position ASL <ARRAY>
 * 1: Selected Objects <ARRAY>
 *
 * Return Value:
 * Order Possible <BOOL>
 *
 * Example:
 * [_position, _objects] call rtz_mine_fnc_canDisarm
 *
 * Public: No
 */

params ["_position", "_objects"];

if (!GVAR(enabled)) exitWith {false};
if (([_objects] call FUNC(getDeminers)) isEqualTo []) exitWith {false};

private _pos = ASLToAGL _position;

allMines findIf {mineActive _x && {_x distance2D _pos <= SEARCH_RADIUS}} != -1
