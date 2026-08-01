#include "script_component.hpp"
/*
 * Author: Maxim
 * SERVER. Destination-stream gatherer: turns one watched entity and its hull
 * into a snapshot entry, or [] when there is nothing worth drawing.
 * FUNC(streamServer) calls this once per hull per tick.
 *
 * The entry carries the WATCHED entity, not the hull — that is what the client
 * matches its selection against — and the raw planningMode string, which the
 * client localises once per snapshot.
 *
 * Arguments:
 * 0: Watched entity <OBJECT>
 * 1: Its hull (vehicle of it) <OBJECT>
 *
 * Return Value:
 * [unit, destination, planningMode, forceReplan] or [] <ARRAY>
 *
 * Example:
 * [_unit, vehicle _unit] call rtz_overlays_fnc_gatherDestination
 *
 * Public: No
 */

params ["_unit", "_veh"];

// Only whoever steers owns a path: a man on foot is his own pilot; a vehicle
// paths through its effective commander (an empty vehicle has nobody, so it
// drops out). Player judgement isn't AI state, and expectedDestination is only
// meaningful where the pathing unit is local — skips remote-controlled and
// HC-offloaded.
private _pathUnit = if (_veh isKindOf "CAManBase") then { _veh } else { effectiveCommander _veh };
if (isNull _pathUnit || {isPlayer _pathUnit} || {!local _pathUnit}) exitWith { [] };

(expectedDestination _pathUnit) params ["_dest", "_mode", "_forceReplan"];
if (_dest isEqualTo [0, 0, 0]) exitWith { [] };                 // no plan at all

private _dist = _veh distance _dest;
if (_dist < ARRIVE_RADIUS) exitWith { [] };                     // idle / arrived
if (_dist > KNOWLEDGE_MAX_DIST) exitWith { [] };

[_unit, _dest, _mode, _forceReplan]
