#include "script_component.hpp"
/*
 * Author: Maxim
 * Asks the engine's own pathfinder for a way to a point the traced line could
 * not reach, so a curator can drag straight at a compound and have the path go
 * round it — or through its doors — instead of stalling against the first wall.
 *
 * This is also why FUNC(validatePoint) makes no attempt to recognise doors.
 * Wargame runs a hand-rolled nearest-door search on every blocked sample to
 * decide whether to forgive the collision; the engine's pathfinder already knows
 * which doors open, and asking it is both simpler and right more often.
 *
 * Asynchronous: calculatePath spawns an agent that answers later through a
 * PathCalculated event. Two things are therefore bounded rather than assumed —
 * only one search runs per path at a time, and the search retires itself after
 * AUTOPATH_TIMEOUT whether or not the engine ever answers. An event that is
 * merely *likely* to fire cannot be allowed to own the only path that deletes
 * the agent (Gotchas §1).
 *
 * The point count at request time is recorded alongside the expiry, because the
 * answer is only meaningful for the head it was asked about. The curator can
 * keep dragging for the whole of AUTOPATH_TIMEOUT, and a detour spliced onto a
 * head that has since moved is a leg jumping backwards through everything drawn
 * in between. FUNC(splicePath) rejects on that count; Wargame guards the same
 * window by comparing the head position.
 *
 * Aircraft and boats are not asked. Neither has anything to path around in the
 * sense the ground pathfinder understands, and a boat path blocked by a
 * headland wants the curator to trace around it, not a land path through it.
 *
 * Arguments:
 * 0: Path record <ARRAY>
 * 1: Position that could not be reached, ASL <ARRAY>
 *
 * Return Value:
 * A search was started <BOOL>
 *
 * Example:
 * [_path, _target] call rtz_path_fnc_autoPath
 *
 * Public: No
 */

params ["_path", "_target"];

_path params ["", "", "_points", "", "_kind", "_head"];

if (_kind == KIND_AIR || {_kind == KIND_BOAT}) exitWith {false};

private _now = CBA_missionTime;

// One search per path at a time. The expiry frees the path by itself if the
// engine never answers; the count is what FUNC(splicePath) tests the answer's
// freshness against.
if (_now < ((_path select PATH_SEARCH) param [0, 0])) exitWith {false};
_path set [PATH_SEARCH, [_now + AUTOPATH_TIMEOUT, count _points]];

private _agent = calculatePath [
    ["man", "wheeled_APC"] select (_kind == KIND_LAND),
    "CARELESS",
    _head,
    _target
];

if (isNull _agent) exitWith {
    _path set [PATH_SEARCH, []];
    false
};

// The record travels on the agent because event handler code does not capture
// locals. It is a reference to the same array FUNC(splicePath) will look up
// again by unit — the lookup is what proves the path is still live, this only
// carries the identity.
_agent setVariable [QGVAR(path), _path];

// The engine's answer arrives as the event's second argument; the record it
// belongs to rides on the agent. Both are needed — bind them to DIFFERENT names.
_agent addEventHandler ["PathCalculated", {
    params ["_agent", "_calculated"];
    private _record = _agent getVariable [QGVAR(path), []];
    deleteVehicle _agent;
    [_record, _calculated] call FUNC(splicePath);
}];

// The event is not guaranteed. Without this the agent outlives the search for
// the rest of the mission.
[{
    params ["_agent"];
    if (!isNull _agent) then {deleteVehicle _agent};
}, [_agent], AUTOPATH_TIMEOUT] call CBA_fnc_waitAndExecute;

true
