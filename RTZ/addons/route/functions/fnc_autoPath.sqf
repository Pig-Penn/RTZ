#include "script_component.hpp"
/*
 * Author: Maxim
 * Asks the engine's own pathfinder for a way to a point the traced line could
 * not reach, so a curator can drag straight at a compound and have the route go
 * round it — or through its doors — instead of stalling against the first wall.
 *
 * This is also why FUNC(validatePoint) makes no attempt to recognise doors.
 * Wargame runs a hand-rolled nearest-door search on every blocked sample to
 * decide whether to forgive the collision; the engine's pathfinder already knows
 * which doors open, and asking it is both simpler and right more often.
 *
 * Asynchronous: calculatePath spawns an agent that answers later through a
 * PathCalculated event. Two things are therefore bounded rather than assumed —
 * only one search runs per route at a time, and the search retires itself after
 * AUTOPATH_TIMEOUT whether or not the engine ever answers. An event that is
 * merely *likely* to fire cannot be allowed to own the only path that deletes
 * the agent (Gotchas §1).
 *
 * Aircraft and boats are not asked. Neither has anything to path around in the
 * sense the ground pathfinder understands, and a boat route blocked by a
 * headland wants the curator to trace around it, not a land route through it.
 *
 * Arguments:
 * 0: Route record <ARRAY>
 * 1: Position that could not be reached, ASL <ARRAY>
 *
 * Return Value:
 * A search was started <BOOL>
 *
 * Example:
 * [_route, _target] call rtz_route_fnc_autoPath
 *
 * Public: No
 */

params ["_route", "_target"];

_route params ["", "", "", "", "_kind", "_head"];

if (_kind == KIND_AIR || {_kind == KIND_BOAT}) exitWith {false};

private _now = CBA_missionTime;

// One search per route at a time. The stamp doubles as the expiry, so a search
// the engine never answers frees the route by itself.
if (_now < (_route select ROUTE_SEARCH)) exitWith {false};
_route set [ROUTE_SEARCH, _now + AUTOPATH_TIMEOUT];

private _agent = calculatePath [
    ["man", "wheeled_APC"] select (_kind == KIND_LAND),
    "CARELESS",
    _head,
    _target
];

if (isNull _agent) exitWith {
    _route set [ROUTE_SEARCH, 0];
    false
};

// The record travels on the agent because event handler code does not capture
// locals. It is a reference to the same array FUNC(splicePath) will look up
// again by unit — the lookup is what proves the route is still live, this only
// carries the identity.
_agent setVariable [QGVAR(route), _route];

_agent addEventHandler ["PathCalculated", {
    params ["_agent", "_path"];
    private _route = _agent getVariable [QGVAR(route), []];
    deleteVehicle _agent;
    [_route, _path] call FUNC(splicePath);
}];

// The event is not guaranteed. Without this the agent outlives the search for
// the rest of the mission.
[{
    params ["_agent"];
    if (!isNull _agent) then {deleteVehicle _agent};
}, [_agent], AUTOPATH_TIMEOUT] call CBA_fnc_waitAndExecute;

true
