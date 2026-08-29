#include "script_component.hpp"
/*
 * Author: Maxim
 * SERVER. Completion pass for a supply vehicle's service job — the
 * EFUNC(common,progressJob) end hook for FUNC(serviceVehicles).
 *
 * Teardown and reporting only. It used to carry the ammo write and a completion
 * SNAP that corrected the drift left by the old per-tick setDamage/setFuel chain;
 * the engine writes the values now, so there is no drift, nothing to snap and
 * nothing to top up here.
 *
 * READ THE FLAG NAMES CAREFULLY. progressJob's second argument means "ran to full
 * progress", and for this job full progress is the TIMEOUT elapsing — the exact
 * inverse of what it meant when the duration was a service length. A finished
 * service stops the loop EARLY, so success arrives with _timedOut false. Success
 * is therefore carried in the job arguments by FUNC(serviceTick) instead of being
 * inferred from the flag, and the flag is used only to pick which failure the
 * curator is told about.
 *
 * Releasing the targets happens on every path and comes first: a job that died two
 * seconds into a sixty second timeout would otherwise leave its targets locked
 * against every other supply vehicle for the rest of the minute. Only claims still
 * held by THIS vehicle are dropped, so releasing can never take a target away from
 * a job that has since claimed it. The expiry the claims carry (see CLAIM_GRACE)
 * stays as the backstop for the one path that does not reach here at all — being
 * superseded by a repeat order, which re-claims what it needs anyway.
 *
 * Arguments:
 * 0: Job Arguments <ARRAY> — [supply, capabilities, work, radius, curator, startTotal, bestProgress, stalls, succeeded, retried]
 * 1: Timed Out <BOOL> — progressJob ran the full timeout without the monitor stopping it
 *
 * Return Value:
 * None
 *
 * Example:
 * [_args, false] call rtz_supply_fnc_endService
 *
 * Public: No
 */

params ["_args", "_timedOut"];
_args params ["_supply", "", "_work", "", "_curator", "", "", "", "_succeeded"];

// Drops the supply-lines overlay for this vehicle however the job ended
if (!isNull _supply) then {
    _supply setVariable [QGVAR(servicing), nil];
};

private _remaining = 0;

{
    private _target = _x select 0;
    if (isNull _target) then { continue };

    _remaining = _remaining + 1;

    if (((_target getVariable [QGVAR(claim), []]) param [0, objNull]) isEqualTo _supply) then {
        _target setVariable [QGVAR(claim), nil];
    };
} forEach _work;

if (isNull _curator) exitWith {};

// The supply vehicle was destroyed mid-order. FUNC(serviceTick) stops on that, so
// it arrives here looking exactly like a stall — and would otherwise tell the
// curator his burning truck had run out of supplies. He watched it explode.
if (!alive _supply) exitWith {};

// The stringtable KEY goes over the wire rather than the localised text, so the
// toast renders in the receiving client's own language instead of the server's.
if (_succeeded) exitWith {
    [QGVAR(report), [LSTRING(MsgResupplyComplete), _remaining], _curator] call CBA_fnc_targetEvent;
};

// Every target died or drove off. The curator watched that happen and does not
// need to be told the order it cancelled itself.
if (_remaining == 0) exitWith {};

// Stalled means the deficit stopped closing with work still to do, and a truck out
// of stock is overwhelmingly the reason. Timed out means it was still closing, just
// not fast enough for SERVICE_TIMEOUT — a different thing, and one the engine
// should never produce for an ordinary order.
[
    QGVAR(report),
    [([LSTRING(MsgSupplyEmpty), LSTRING(MsgServiceIncomplete)] select _timedOut), _remaining],
    _curator
] call CBA_fnc_targetEvent;
