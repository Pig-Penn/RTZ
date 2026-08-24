#include "script_component.hpp"
/*
 * Author: Maxim
 * Replaces the group's waypoints with a destroy waypoint attached to the
 * target and reveals the target to the group so it engages reliably.
 * Must be executed where the group is local.
 *
 * Arguments:
 * 0: Group <GROUP>
 * 1: Target <OBJECT>
 *
 * Return Value:
 * None
 *
 * Example:
 * [_group, _target] call rtz_attack_fnc_addWaypoint
 *
 * Public: No
 */

params ["_group", "_target"];

if (isNull _group || {isNull _target} || {!alive _target}) exitWith {};

// A new order supersedes all existing waypoints, except the implicit waypoint 0
// every group is created with: that is the one the group is already standing on,
// so an order placed there can be treated as reached the moment it is set
private _waypoints = waypoints _group;
_waypoints deleteAt 0;
{
    deleteWaypoint _x;
} forEachReversed _waypoints;

// Without the reveal the group may reach the waypoint but never spot,
// and therefore never engage, the target
_group reveal [_target, REVEAL_ACCURACY];

private _waypoint = _group addWaypoint [_target, 0];
_waypoint setWaypointType "DESTROY";
_waypoint waypointAttachVehicle _target;
_waypoint setWaypointBehaviour "COMBAT";
_waypoint setWaypointCombatMode "RED";
_group setCurrentWaypoint _waypoint;
