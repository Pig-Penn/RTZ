#include "script_component.hpp"
/*
 * Author: Maxim
 * SERVER. Supply-lines gatherer: turns one watched entity and its hull into a
 * snapshot entry for the rtz_hud stream engine, or [] when that hull is not
 * currently servicing anything. EFUNC(core,streamServer) calls this once per
 * hull per tick for every curator subscribed to STREAM_SUPPLY.
 *
 * The engine is a client of this addon here, not the other way round: the entire
 * contract is the QGVAR(servicing) record FUNC(serviceVehicles) writes and
 * FUNC(serviceTick) keeps current. Both it and this run on the server, so nothing
 * is broadcast to produce the overlay.
 *
 * The times are reported ABSOLUTE (server clock) rather than as a progress
 * figure. A progress figure changes every tick and would defeat the engine's send
 * diff, making a running order the only thing on the wire; a start time and a
 * duration are both frozen for the life of the job, so after the first send an
 * unchanging order costs nothing at all and the client interpolates the bar
 * itself — smoothly, per frame, instead of stepping once per poll. Identical
 * reasoning to EFUNC(hud,gatherTarget) reporting sighting times.
 *
 * Arguments:
 * 0: Watched entity <OBJECT>
 * 1: Its hull (vehicle of it) <OBJECT>
 *
 * Return Value:
 * [unit, targets, startTime, duration] or [] <ARRAY>
 *
 * Example:
 * [_unit, vehicle _unit] call rtz_supply_fnc_gatherSupply
 *
 * Public: No
 */

params ["_unit", "_veh"];

private _record = _veh getVariable [QGVAR(servicing), []];
if (_record isEqualTo []) exitWith { [] };

_record params ["_targets", "_startTime", "_duration"];

// Dead targets are pruned by the tick, but only on its own cadence — a kill
// between the two loops would otherwise be drawn as a live supply line. Filtered
// by value into a new array, so an unchanged target set still diffs away.
_targets = _targets select {!isNull _x && {alive _x}};
if (_targets isEqualTo []) exitWith { [] };

[_unit, _targets, _startTime, _duration]
