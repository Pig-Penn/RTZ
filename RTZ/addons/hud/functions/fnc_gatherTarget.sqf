#include "script_component.hpp"
/*
 * Author: Maxim
 * SERVER. Target-stream gatherer: turns one watched entity and its hull into a
 * snapshot entry, or [] when there is nothing worth drawing.
 * EFUNC(core,streamServer) calls this once per hull per tick.
 *
 * The position reported is the AI's ESTIMATED target position (targetKnowledge),
 * not the target's true one — stale knowledge points at where the target was
 * last seen, and the client dims the overlay as that sighting ages.
 *
 * The sighting time is reported ABSOLUTE (server clock) rather than as an age.
 * An age would change every tick and defeat EFUNC(core,streamServer)'s send diff; a
 * frozen absolute timestamp lets an unchanged snapshot cost nothing, and the
 * client ages it per frame against the reference time in the packet — which is
 * also what makes the stale-dim fade smoothly instead of stepping once per poll.
 *
 * Arguments:
 * 0: Watched entity <OBJECT>
 * 1: Its hull (vehicle of it) <OBJECT>
 *
 * Return Value:
 * [unit, target, estimatedPos, lastSeen, positionError, targetSide] or [] <ARRAY>
 *
 * Example:
 * [_unit, vehicle _unit] call rtz_hud_fnc_gatherTarget
 *
 * Public: No
 */

params ["_unit", "_veh"];

// Whoever aims the weapon holds the sensor knowledge: the man himself on foot,
// the gunner (or failing that the commander / driver) for a vehicle. Player
// judgement isn't AI state.
private _kUnit = if (_veh isKindOf "CAManBase") then { _veh } else {
    private _g = gunner _veh;
    if (isNull _g) then { effectiveCommander _veh } else { _g }
};
// Locality is tested on the KNOWLEDGE HOLDER, not on the hull: assignedTarget
// and targetKnowledge are only meaningful where the unit they are asked about
// is local, and a vehicle can be local here while its gunner belongs to a group
// owned elsewhere. Skips remote-controlled and HC-offloaded crews.
if (isNull _kUnit || {isPlayer _kUnit} || {!local _kUnit}) exitWith { [] };

private _target = assignedTarget _kUnit;
if (isNull _target || {!alive _target}) exitWith { [] };

// Friendly "targets" (watch / cover assignments) are noise.
private _tSide = side _target;
if (_tSide isEqualTo side group _kUnit) exitWith { [] };

// Where the AI believes the target is: index 2 = time of the last sighting,
// 5 = position error (m), 6 = estimated position ASL.
private _kn = _kUnit targetKnowledge _target;
private _estPos = ASLToAGL (_kn select 6);
// Degenerate knowledge position while actively suppressing — fall back to the
// true position (same fix as LAMBS). ASLToAGL, matching the line above: this is
// the SAME variable, and the renderer feeds it straight to drawLine3D /
// drawIcon3D, which take AGL. A getPosATL here put the fallback in a different
// space from the primary path — identical over land, out by the water depth over
// sea, and decided by a branch the reader cannot see from the draw site.
if (_estPos distanceSqr [0, 0, 0] < 1) then {
    _estPos = ASLToAGL getPosASL _target;
};
if (_veh distance _estPos > KNOWLEDGE_MAX_DIST) exitWith { [] };

[_unit, _target, _estPos, _kn select 2, _kn select 5, _tSide]
