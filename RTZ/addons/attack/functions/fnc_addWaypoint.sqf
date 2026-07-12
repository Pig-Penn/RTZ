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

// A new order supersedes all existing waypoints
{
    deleteWaypoint _x;
} forEachReversed (waypoints _group);

// Without the reveal the group may reach the waypoint but never spot,
// and therefore never engage, the target
_group reveal [_target, REVEAL_ACCURACY];

private _waypoint = _group addWaypoint [_target, 0];
_waypoint setWaypointType "DESTROY";
_waypoint waypointAttachVehicle _target;
_waypoint setWaypointBehaviour "COMBAT";
_waypoint setWaypointCombatMode "RED";
_group setCurrentWaypoint _waypoint;

// The engine completes the waypoint once the target is destroyed, but a
// target deleted by Zeus would leave the group stuck on it forever
[{
    params ["_group", "_target"];
    isNull _group || {isNull _target} || {!alive _target}
}, {
    params ["_group", "_target", "_waypoint"];

    if (isNull _group || {!isNull _target}) exitWith {};

    // The index may be stale if the waypoints were edited since, only
    // delete what is still recognizable as an orphaned destroy waypoint
    if (waypointType _waypoint == "DESTROY" && {isNull waypointAttachedVehicle _waypoint}) then {
        deleteWaypoint _waypoint;
    };
}, [_group, _target, _waypoint]] call CBA_fnc_waitUntilAndExecute;
