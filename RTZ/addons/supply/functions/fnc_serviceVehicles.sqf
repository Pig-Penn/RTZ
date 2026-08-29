#include "script_component.hpp"
/*
 * Author: Maxim
 * SERVER. Starts one supply vehicle's order: validates the target list the
 * curator's client sent, claims what is still free, snapshots each target's
 * deficit, fires the engine's service actions at the targets' own machines, and
 * hands the WATCHING to EFUNC(common,progressJob). The per-tick body is
 * FUNC(serviceTick) and the completion pass is FUNC(endService).
 *
 * The job is a monitor, not a driver. This component no longer applies anything
 * over time — FUNC(applyService) hands the work to the engine in one shot and the
 * loop exists only to watch the deficit close, keep the supply-lines overlay
 * honest, release the claims and report. That is why the duration handed to
 * progressJob is SERVICE_TIMEOUT and not a service length: it is the point at
 * which watching gives up, not the point at which the work finishes.
 *
 * The capabilities are recomputed here rather than taken from the wire. They used
 * to ride along with the order, which meant a stale or hand-crafted client event
 * could ask a troop truck to rearm a tank. They are now read from the truck's live
 * cargo levels, so recomputing also catches the case the old class cache could
 * not see at all: a truck that ran dry between the menu opening and the click.
 *
 * Targets are CLAIMED for the timeout (plus CLAIM_GRACE). Two supply vehicles
 * parked together see each other's targets, and each job measures progress from
 * its own deficit snapshot, so letting both take one vehicle makes each read the
 * other's work as its own. FUNC(orderResupply) already de-duplicates within a
 * single order, but that is a client-side list and cannot see an order issued a
 * second ago, or one issued by a different curator — this is the guard that
 * actually holds.
 *
 * Arguments:
 * 0: Supply Vehicle <OBJECT>
 * 1: Targets To Service <ARRAY>
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

private _capabilities = [_supply] call FUNC(supplyCapabilities);
if !(true in _capabilities) exitWith {};

// Side is judged from the crewed GROUP, the same test FUNC(findTargets) makes and
// the same one VEH_SIDE_OK makes: a crewless hull has no meaningful side and stays
// serviceable, a manned hostile one does not.
private _supplyGroup = group _supply;
private _checkSide   = !isNull _supplyGroup;
private _supplySide  = side _supplyGroup;

private _radius  = GVAR(serviceRadius);
private _timeout = SERVICE_TIMEOUT;
private _until   = CBA_missionTime + _timeout + CLAIM_GRACE;

// Snapshot layout per entry: [target, startDeficit]. One number, not the old
// [damage, fuel] pair, because the monitor no longer reproduces each service — it
// only needs the SIZE of the hole it is watching close.
private _work       = [];
private _serviced   = [];
private _startTotal = 0;

{
    // Re-validated server-side: the list was resolved on the curator's client a
    // network hop ago, so anything in it may have died, driven off, mounted up or
    // never been an object at all.
    if (!(_x isEqualType objNull)) then { continue };
    if (isNull _x || {!alive _x} || {_x isEqualTo _supply}) then { continue };
    if (!(_x isKindOf "AllVehicles") || {_x isKindOf "CAManBase"}) then { continue };
    if (_x distance _supply > _radius) then { continue };

    // Re-checked here and not merely on the client, for the same reason the
    // capabilities are recomputed: the list arrives over the wire, and a stale or
    // hand-crafted event must not be able to talk a truck into rearming the enemy.
    private _group = group _x;
    if (_checkSide && {!isNull _group} && {_supplySide getFriend (side _group) < FRIENDLY_THRESHOLD}) then { continue };

    private _deficit = [_x, _capabilities] call FUNC(serviceDeficit);
    if (_deficit <= 0) then { continue };

    // Free if nobody holds it, the holder is this same truck (a repeat order
    // supersedes its own job rather than being blocked by it), the holder is
    // gone, or the claim has simply run out.
    (_x getVariable [QGVAR(claim), []]) params [["_by", objNull], ["_expires", 0]];
    if (!isNull _by && {_by isNotEqualTo _supply} && {alive _by} && {CBA_missionTime < _expires}) then {
        continue;
    };

    _x setVariable [QGVAR(claim), [_supply, _until]];

    _work pushBack [_x, _deficit];
    _serviced pushBack _x;
    _startTotal = _startTotal + _deficit;
} forEach _targets;

if (_work isEqualTo []) exitWith {};

// Contract read by FUNC(gatherSupply) for the supply-lines overlay: the target
// list is mutated in place by FUNC(serviceTick) as targets drop, and the start
// time is `time` (not CBA_missionTime) because that is the clock the overlay
// engine's snapshots are stamped against. The duration starts as the timeout and
// is re-stamped by the monitor once the real pace is known — the client draws the
// bar by linear interpolation and has no other way to be told. Server-side only:
// the gatherer runs on the server too, so there is nothing to broadcast.
_supply setVariable [QGVAR(servicing), [_serviced, time, _timeout]];

// The one and only write. Sent with the whole array as the CBA target so it is
// delivered once per owning machine; FUNC(applyService) filters to what that
// machine holds.
[QGVAR(service), [_supply, _serviced, _capabilities], _serviced] call CBA_fnc_targetEvent;

[
    _supply,
    "supply",
    _timeout,
    SERVICE_TICK,
    LINKFUNC(serviceTick),
    // Mutable across ticks — progressJob hands the same array back every time:
    // [supply, capabilities, work, radius, curator, startTotal, bestProgress,
    //  stalls, succeeded]
    [_supply, _capabilities, _work, _radius, _curator, _startTotal, 0, 0, false],
    LINKFUNC(endService)
] call EFUNC(common,progressJob);
