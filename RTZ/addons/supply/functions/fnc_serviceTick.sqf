#include "script_component.hpp"
/*
 * Author: Maxim
 * SERVER. One tick of a supply vehicle's service job — the EFUNC(common,progressJob)
 * step body for FUNC(serviceVehicles).
 *
 * This is a MONITOR, not a driver. It used to apply each tick's share of a
 * vehicle's deficit with setDamage and setFuel; the engine performs the services
 * now (FUNC(applyService)), reports nothing about them, and this watches the
 * deficit close instead. Three jobs, none of which the engine does for us:
 *
 *  — DROP the target if it died or drove out of range, releasing its claims.
 *  — MEASURE progress, as the fraction of the starting deficit that has closed,
 *    and keep the supply-lines overlay's straight line honest about it.
 *  — GIVE UP when the deficit stops falling, which is what a supply truck running
 *    dry looks like from here.
 *
 * The step SHARE that progressJob hands every other job in the mod is deliberately
 * ignored: nothing here is applied over time, so there is no share to apply. The
 * duration this job was started with is a TIMEOUT, not a service length.
 *
 * ONE TARGET, since FUNC(orderResupply) became a picker. This carried a target list
 * with a mark-and-compact pass, a running total the dropped entries had to be
 * subtracted from, and a per-entry claim release — all of which existed to keep one
 * job's arithmetic straight across a blanket sweep's worth of vehicles. A job now
 * watches exactly one deficit close.
 *
 * Progress is measured against the GRANTED services, not everything the truck
 * carries: a fuel truck whose fuel slot was already claimed elsewhere is not
 * watching that tank's fuel and must not read another truck's work as its own.
 *
 * Arguments:
 * 0: Job Arguments <ARRAY> — [supply, granted, target, startDeficit, radius, curator, bestProgress, stalls, succeeded]
 *
 * Return Value:
 * Keep Going <BOOL>
 *
 * Example:
 * [_args] call rtz_supply_fnc_serviceTick
 *
 * Public: No
 */

params ["_args"];
_args params ["_supply", "_granted", "_target", "_startDeficit", "_radius", "", "_bestProgress", "_stalls"];

if (!alive _supply) exitWith {false};

// Leaving the radius drops the target from the ORDER, not from the service:
// actionNow has no distance limit, so the engine will finish whatever it started
// however far the vehicle drives. This is RTZ's own policy bound — what a curator
// meant by aiming at a vehicle parked next to this truck — and all it costs a
// vehicle that drives off is its supply line and its claims.
if (!alive _target || {_target distance _supply > _radius}) exitWith {
    // Released here rather than left to FUNC(endService), which sees the nulled
    // slot below and has nothing to release: a vehicle that drove into another
    // depot's radius would otherwise stay locked against every other supply
    // vehicle until the claim's own expiry.
    [_target, _supply] call FUNC(releaseClaims);

    // Nulled so FUNC(endService) can tell "the target left" from "the truck ran
    // dry" — the first is something the curator watched happen and is not told
    // about, the second is a report he needs.
    _args set [2, objNull];

    false
};

private _remaining = [_target, _granted] call FUNC(serviceDeficit);

private _progress = 1;
if (_startDeficit > 0) then {
    _progress = (((_startDeficit - _remaining) / _startDeficit) max 0) min 1;
};

// Done. Stop rather than idle out the rest of the timeout.
if (_remaining <= 0) exitWith {
    _args set [8, true];
    false
};

if (_progress > _bestProgress + PROGRESS_EPSILON) then {
    _args set [6, _progress];
    _args set [7, 0];
    _stalls = 0;
} else {
    _stalls = _stalls + 1;
    _args set [7, _stalls];
};

// The deficit has stopped falling with work still to do, which means the supply
// vehicle has run out. The engine simply declines to service anything once a store
// is spent — it does not report that, it just does nothing — so watching the work
// fail to happen IS the read on an empty truck. There is deliberately no re-issue:
// a refused action is refused for a reason that re-sending cannot change.
if (_stalls >= STALL_TICKS) exitWith {
    _args set [8, false];
    false
};

// Keep the client's straight line honest. It draws (now - startTime) / duration,
// so setting duration to (elapsed / observed progress) makes that land exactly on
// the observed figure and re-projects the finish from there — startTime never
// moves, so an unchanged job still diffs away and costs nothing on the wire.
// Compared against what the client is ACTUALLY drawing, not against progressJob's
// own clock: once re-stamped, the two no longer agree, and comparing against the
// job clock would re-stamp every single tick and defeat the stream's send-diff.
private _record = _supply getVariable [QGVAR(servicing), []];
if (_record isNotEqualTo [] && {_progress > 0}) then {
    _record params ["", "_startTime", "_duration"];
    private _shown = ((((time - _startTime) / (_duration max 1)) max 0) min 1);

    if (abs (_progress - _shown) > PROGRESS_DRIFT) then {
        _record set [2, ((time - _startTime) / _progress) max 1];
    };
};

true
