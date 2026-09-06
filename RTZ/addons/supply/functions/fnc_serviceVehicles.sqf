#include "script_component.hpp"
/*
 * Author: Maxim
 * SERVER. Starts one supply vehicle's service job against ONE target: validates
 * what the curator's client sent, works out which services are still free to take,
 * claims them, snapshots the deficit, fires the engine's service actions at the
 * target's own machine, and hands the WATCHING to EFUNC(common,progressJob). The
 * per-tick body is FUNC(serviceTick) and the completion pass is FUNC(endService).
 *
 * The job is a monitor, not a driver. This component no longer applies anything
 * over time — FUNC(applyService) hands the work to the engine in one shot and the
 * loop exists only to watch the deficit close, keep the supply-lines overlay
 * honest, release the claims and report. That is why the duration handed to
 * progressJob is SERVICE_TIMEOUT and not a service length: it is the point at which
 * watching gives up, not the point at which the work finishes.
 *
 * ONE TARGET, not a list. This took an array for as long as the order was a blanket
 * radius sweep; FUNC(orderResupply) is a picker now and one click carries one
 * vehicle, so a list would always have held exactly one entry — and it is what made
 * the granted capabilities awkward, since two targets in one order can be owed
 * different services. One call per (truck, target) pair keeps a job's capability set
 * a single value it can be started with.
 *
 * GRANTED, not carried. The capabilities are recomputed here rather than taken from
 * the wire — a stale or hand-crafted client event must not be able to talk a troop
 * truck into rearming a tank — and are then narrowed by FUNC(grantedServices) to the
 * claim slots no other live truck holds. That narrowing is what lets a repair truck
 * and a fuel truck work one damaged, empty tank TOGETHER while two fuel trucks
 * cannot both take the fuel, and it is the guard that actually holds: the client
 * checked the same thing a network hop ago, and cannot see an order issued since.
 *
 * Arguments:
 * 0: Supply Vehicle <OBJECT>
 * 1: Target To Service <OBJECT>
 * 2: Ordering Curator <OBJECT> (default: objNull)
 *
 * Return Value:
 * None
 *
 * Example:
 * [_truck, _tank, player] call rtz_supply_fnc_serviceVehicles
 *
 * Public: No
 */

params ["_supply", "_target", ["_curator", objNull]];

if (isNull _supply || {!alive _supply}) exitWith {};

// Re-validated server-side: the target was resolved on the curator's client a
// network hop ago, so it may have died, driven off, mounted up or never been an
// object at all.
if (!(_target isEqualType objNull)) exitWith {};
if (isNull _target || {!alive _target} || {_target isEqualTo _supply}) exitWith {};
if (!(_target isKindOf "AllVehicles") || {_target isKindOf "CAManBase"}) exitWith {};

private _radius = GVAR(serviceRadius);
if (_target distance _supply > _radius) exitWith {};

// Side is judged from the crewed GROUP, the same test FUNC(serviceProviders) makes
// and the same one VEH_SIDE_OK makes: a crewless hull has no meaningful side and
// stays serviceable, a manned hostile one does not. Written flat rather than nested
// because exitWith inside a `then` block unwinds only that block.
private _supplyGroup = group _supply;
private _targetGroup = group _target;

if (
    !isNull _supplyGroup
    && {!isNull _targetGroup}
    && {side _supplyGroup getFriend (side _targetGroup) < FRIENDLY_THRESHOLD}
) exitWith {};

private _capabilities = [_supply] call FUNC(supplyCapabilities);
private _granted      = [_target, _supply, _capabilities] call FUNC(grantedServices);

if !(true in _granted) exitWith {};

// Measured against the GRANTED services only, not everything the truck carries: a
// fuel truck arriving at a tank whose fuel another truck already claimed has no
// deficit to close here, however empty the tank still looks.
private _deficit = [_target, _granted] call FUNC(serviceDeficit);
if (_deficit <= 0) exitWith {};

private _timeout = SERVICE_TIMEOUT;
private _until   = CBA_missionTime + _timeout + CLAIM_GRACE;

// A second order on this truck SUPERSEDES its running job, and EFUNC(common,progressJob)
// removes a superseded job WITHOUT running its end hook — so the previous target's
// claims are never released by FUNC(endService) and sit locked against every other
// supply vehicle until their own expiry, the best part of a minute later.
//
// That was survivable while this order was a blanket sweep, because a repeat order
// re-claimed the same vehicles anyway. It is not survivable now: one click carries
// one vehicle, so re-tasking a truck to the vehicle next to it is the ORDINARY way
// to use the picker, and each re-task would strand the last one. Released here from
// the record the old job left behind, and BEFORE the new claim below — a re-task
// aimed back at the same vehicle would otherwise release the slots it just took.
private _previous = _supply getVariable [QGVAR(servicing), []];

if (_previous isNotEqualTo []) then {
    { [_x, _supply] call FUNC(releaseClaims) } forEach (_previous select 0);
};

// Claim slots carry an expiry as well as being released by FUNC(releaseClaims), so
// that a superseded job, a destroyed supply truck or an order that stopped early can
// never strand a service as permanently unclaimable.
private _claim = _target getVariable [QGVAR(claim), []];
if (count _claim < 3) then { _claim = [[], [], []] };

{
    if (_x) then { _claim set [_forEachIndex, [_supply, _until]] };
} forEach _granted;

_target setVariable [QGVAR(claim), _claim];

// Contract read by FUNC(gatherSupply) for the supply-lines overlay. The target is
// wrapped in a one-element array because that gatherer and FUNC(drawSupply) take a
// target LIST and neither needs to change for this: two trucks servicing one vehicle
// simply draw two lines from two origins, which is the correct reading of what is
// happening. The start time is `time` (not CBA_missionTime) because that is the
// clock the overlay engine's snapshots are stamped against; the duration starts as
// the timeout and is re-stamped by the monitor once the real pace is known.
// Server-side only: the gatherer runs on the server too, so nothing is broadcast.
_supply setVariable [QGVAR(servicing), [[_target], time, _timeout]];

// The one and only write, dispatched to the machine that owns the target — `action`
// and `actionNow` take a LOCAL argument, and the server firing one on a vehicle it
// does not own is a silent no-op.
[QGVAR(service), [_supply, _target, _granted], _target] call CBA_fnc_targetEvent;

[
    _supply,
    "supply",
    _timeout,
    SERVICE_TICK,
    LINKFUNC(serviceTick),
    // Mutable across ticks — progressJob hands the same array back every time:
    // [supply, granted, target, startDeficit, radius, curator, bestProgress,
    //  stalls, succeeded]
    [_supply, _granted, _target, _deficit, _radius, _curator, 0, 0, false],
    LINKFUNC(endService)
] call EFUNC(common,progressJob);
