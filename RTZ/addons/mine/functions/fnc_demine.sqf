#include "script_component.hpp"
/*
 * Author: Maxim
 * Sends the group to clear mines around the position with the vanilla demine
 * behaviour, which walks its engineers/specialists to each mine and defuses
 * it. Existing waypoints are dropped first so the order supersedes any current
 * task. Must be executed where the group is local.
 *
 * Arguments:
 * 0: Group <GROUP>
 * 1: Position AGL <ARRAY>
 * 2: Clear Undetected Mines <BOOL>
 *
 * Return Value:
 * None
 *
 * Example:
 * [_group, _pos, false] call rtz_mine_fnc_demine
 *
 * Public: No
 */

params ["_group", "_position", "_clearUnknownMines"];

if (isNull _group) exitWith {};

// A new order supersedes all existing waypoints
{
    deleteWaypoint _x;
} forEachReversed (waypoints _group);

[_group, _position, objNull, _clearUnknownMines] call BIS_fnc_wpDemine;
