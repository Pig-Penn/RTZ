#include "script_component.hpp"
/*
 * Author: Maxim
 * Replaces the group's waypoints with a destroy waypoint aimed at the target
 * and reveals the target to the group so it engages reliably.
 * Must be executed where the group is local.
 *
 * Against a VEHICLE this is a standing order: the waypoint binds to the target,
 * tracks it, and completes when it dies. Against INFANTRY it is a one-shot nudge
 * that the engine retires within seconds - a waypoint cannot be bound to a man.
 * That is an engine limit, not an RTZ one; vanilla Zeus's right-click attack
 * order behaves identically. See docs/Knowledge Base/Gotchas.md 5.
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

if (isNull _group || { isNull _target } || { !alive _target }) exitWith {};

// Without the reveal the group may reach the waypoint but never spot,
// and therefore never engage, the target
_group reveal [_target, REVEAL_ACCURACY];

private _waypoint = _group addWaypoint [_target, 0];
_waypoint setWaypointType "DESTROY";
_waypoint waypointAttachVehicle _target;
_waypoint setWaypointBehaviour "COMBAT";
_waypoint setWaypointCombatMode "RED";
