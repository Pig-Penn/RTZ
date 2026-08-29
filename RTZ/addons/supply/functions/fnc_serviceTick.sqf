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
 *  — DROP targets that died or drove out of range, releasing their claims.
 *  — MEASURE progress, as the fraction of the starting deficit that has closed,
 *    and keep the supply-lines overlay's straight line honest about it.
 *  — GIVE UP when the deficit stops falling, which is what a supply truck running
 *    dry looks like from here.
 *
 * The step SHARE that progressJob hands every other job in the mod is deliberately
 * ignored: nothing here is applied over time, so there is no share to apply. The
 * duration this job was started with is a TIMEOUT, not a service length.
 *
 * A dropped target's starting deficit is subtracted from the total. Without that,
 * a vehicle driving off would shrink the remaining deficit without any work having
 * been done and the bar would jump forward to celebrate losing a target.
 *
 * Arguments:
 * 0: Job Arguments <ARRAY> — [supply, capabilities, work, radius, curator, startTotal, bestProgress, stalls, succeeded]
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
_args params ["_supply", "_capabilities", "_work", "_radius", "", "_startTotal", "_bestProgress", "_stalls"];

if (!alive _supply) exitWith {false};

private _dropped   = false;
private _remaining = 0;

{
    _x params ["_target", "_startDeficit"];

    // Leaving the radius drops a target from the ORDER, not from the service:
    // actionNow has no distance limit, so the engine will finish whatever it
    // started however far the vehicle drives. This is RTZ's own policy bound —
    // what a curator meant by "the vehicles around this truck" — and all it costs
    // a vehicle that drives off is its supply line and its claim.
    if (!alive _target || {_target distance _supply > _radius}) then {
        // Release the claim on the way out. FUNC(endService) only releases what is
        // still in _work, so a target dropped here would otherwise stay locked
        // against every other supply vehicle until the claim's own expiry — for a
        // vehicle that just drove into another depot's radius, that is the rest of
        // this job's timeout plus CLAIM_GRACE. Only a claim still held by THIS
        // vehicle is dropped, same rule as the end pass.
        if (!isNull _target && {((_target getVariable [QGVAR(claim), []]) param [0, objNull]) isEqualTo _supply}) then {
            _target setVariable [QGVAR(claim), nil];
        };

        // Marked rather than deleted so the list is compacted at most once per
        // tick instead of being re-indexed mid-iteration.
        _x set [0, objNull];
        _startTotal = _startTotal - _startDeficit;
        _dropped = true;
        continue;
    };

    _remaining = _remaining + ([_target, _capabilities] call FUNC(serviceDeficit));
} forEach _work;

if (_dropped) then {
    _work = _work select {!isNull (_x select 0)};
    _args set [2, _work];
    _args set [5, _startTotal max 0];

    // Keep the overlay contract in step, so a vehicle that drove off stops being
    // drawn as serviced. The record array is mutated in place — it is the same
    // array FUNC(gatherSupply) reads off the supply vehicle, so there is nothing
    // to write back.
    private _record = _supply getVariable [QGVAR(servicing), []];
    if (_record isNotEqualTo []) then {
        _record set [0, _work apply {_x select 0}];
    };
};

// Everything died or drove off. Not a success and not a failure worth a toast —
// the curator watched it happen.
if (_work isEqualTo []) exitWith {false};

private _progress = 1;
if (_startTotal > 0) then {
    _progress = (((_startTotal - _remaining) / _startTotal) max 0) min 1;
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
