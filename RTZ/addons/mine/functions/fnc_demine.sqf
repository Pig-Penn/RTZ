#include "script_component.hpp"
/*
 * Author: Maxim
 * Sends the group to clear mines around the position with the vanilla demine
 * behaviour, which walks its engineers/specialists to each mine and defuses it.
 * Must be executed where the group is local.
 *
 * The waypoint wipe is not incidental tidying — BIS_fnc_wpDemine builds the sweep
 * out of waypoints it appends to the group, so anything already queued would run
 * before the sweep ever started. Clearing first is what makes the order take
 * effect now instead of after the group's current patrol finishes.
 *
 * Arguments:
 * 0: Group <GROUP>
 * 1: Position AGL <ARRAY>
 * 2: Clear Undetected Mines <BOOL> — sweep the whole area rather than only the
 *    mines the group's side has already spotted
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

if (isNull _group || {units _group isEqualTo []}) exitWith {};

// A new order supersedes all existing waypoints, except the implicit waypoint 0
// every group is created with: that is the one the group is already standing on,
// so an order placed there can be treated as reached the moment it is set
private _waypoints = waypoints _group;
_waypoints deleteAt 0;
{
    deleteWaypoint _x;
} forEachReversed _waypoints;

[_group, _position, objNull, _clearUnknownMines] call BIS_fnc_wpDemine;
