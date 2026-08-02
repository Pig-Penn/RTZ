#include "script_component.hpp"
/*
 * Author: Maxim
 * SERVER. Starts one supply vehicle's order: validates the target list the
 * curator's client sent, claims what is still free, snapshots it and hands the
 * work to EFUNC(common,progressJob). The per-tick body is FUNC(serviceTick) and
 * the completion pass is FUNC(endService).
 *
 * The capabilities are recomputed here rather than taken from the wire. They
 * used to ride along with the order, which meant a stale or hand-crafted client
 * event could ask a troop truck to rearm a tank; the lookup is class-cached, so
 * trusting nothing costs nothing.
 *
 * Targets are CLAIMED for the duration of the job (plus CLAIM_GRACE). Two supply
 * vehicles parked together see each other's targets, and each job interpolates
 * from its own snapshot, so letting both take one vehicle makes them overwrite
 * each other's fuel and damage every tick. FUNC(orderResupply) already
 * de-duplicates within a single order, but that is a client-side list and cannot
 * see an order issued a second ago, or one issued by a different curator — this
 * is the guard that actually holds.
 *
 * Arguments:
 * 0: Supply Vehicle <OBJECT>
 * 1: Vehicles To Service <ARRAY>
 * 2: Ordering Curator <OBJECT> (default: objNull)
 *
 * Return Value:
 * None
 *
 * Example:
 * [_truck, _targets, player] call rtz_supply_fnc_serviceVehicles
 *
 * Public: No
 */

params ["_supply", "_targets", ["_curator", objNull]];

if (isNull _supply || {!alive _supply} || {_targets isEqualTo []}) exitWith {};

([_supply] call FUNC(supplyCapabilities)) params ["_canRepair", "_canRefuel", "_canRearm"];
if (!_canRepair && {!_canRefuel} && {!_canRearm}) exitWith {};

private _radius   = GVAR(serviceRadius);
private _duration = GVAR(serviceDuration) max 1;
private _until    = CBA_missionTime + _duration + CLAIM_GRACE;

// Snapshot layout per entry: [vehicle, startDamage, startFuel]. The snapshot
// doubles as the needs-this-service test — a vehicle pulled in for fuel alone
// never pays for a setDamage that would write back the value it already has.
private _work     = [];
private _vehicles = [];

{
    // Re-validated server-side: the list was resolved on the curator's client a
    // network hop ago, so anything in it may have died, driven off or never been
    // a vehicle at all.
    if (!(_x isEqualType objNull)) then { continue };
    if (isNull _x || {!alive _x} || {_x isEqualTo _supply}) then { continue };
    if (!(_x isKindOf "AllVehicles") || {_x isKindOf "CAManBase"}) then { continue };
    if (_x distance _supply > _radius) then { continue };

    // Free if nobody holds it, the holder is this same truck (a repeat order
    // supersedes its own job rather than being blocked by it), the holder is
    // gone, or the claim has simply run out.
    (_x getVariable [QGVAR(claim), []]) params [["_by", objNull], ["_expires", 0]];
    if (!isNull _by && {_by isNotEqualTo _supply} && {alive _by} && {CBA_missionTime < _expires}) then {
        continue;
    };

    _x setVariable [QGVAR(claim), [_supply, _until]];

    _work pushBack [_x, damage _x, fuel _x];
    _vehicles pushBack _x;
} forEach _targets;

if (_work isEqualTo []) exitWith {};

// Contract read by FUNC(gatherSupply) for the supply-lines overlay: the vehicle
// list is mutated in place by FUNC(serviceTick) as targets drop, and the start
// time is `time` (not CBA_missionTime) because that is the clock the overlay
// engine's snapshots are stamped against. Server-side only — the gatherer runs
// on the server too, so there is nothing to broadcast.
_supply setVariable [QGVAR(servicing), [_vehicles, time, _duration]];

[
    _supply,
    "supply",
    _duration,
    GVAR(serviceInterval) max SERVICE_TICK_MIN,
    LINKFUNC(serviceTick),
    [_supply, _canRepair, _canRefuel, _canRearm, _work, _radius, _curator],
    LINKFUNC(endService)
] call EFUNC(common,progressJob);
