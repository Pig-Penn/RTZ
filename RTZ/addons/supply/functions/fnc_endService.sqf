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
 * Releasing the target happens on every path and comes first: a job that died two
 * seconds into a sixty second timeout would otherwise leave its claim slots locked
 * against every other supply vehicle for the rest of the minute. FUNC(releaseClaims)
 * drops only slots still held by THIS vehicle, so releasing can never take a service
 * away from a job that has since claimed it. The expiry the claims carry (see
 * CLAIM_GRACE) stays as the backstop for the one path that does not reach here at
 * all — being superseded by a repeat order, which re-claims what it needs anyway.
 *
 * A NULL TARGET means FUNC(serviceTick) dropped it: the vehicle died or drove out
 * of range, having already been released there. That is the one ending the curator
 * is not told about, because he watched it happen.
 *
 * Arguments:
 * 0: Job Arguments <ARRAY> — [supply, granted, target, startDeficit, radius, curator, bestProgress, stalls, succeeded]
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
_args params ["_supply", "", "_target", "", "", "_curator", "", "", "_succeeded"];

// Drops the supply-lines overlay for this vehicle however the job ended
if (!isNull _supply) then {
    _supply setVariable [QGVAR(servicing), nil];
};

[_target, _supply] call FUNC(releaseClaims);

if (isNull _curator) exitWith {};

// The supply vehicle was destroyed mid-order. FUNC(serviceTick) stops on that, so
// it arrives here looking exactly like a stall — and would otherwise tell the
// curator his burning truck had run out of supplies. He watched it explode.
if (!alive _supply) exitWith {};

// The stringtable KEY goes over the wire rather than the localised text, so the
// toast renders in the receiving client's own language instead of the server's.
if (_succeeded) exitWith {
    [QGVAR(report), [LSTRING(MsgResupplyComplete)], _curator] call CBA_fnc_targetEvent;
};

// The target died or drove off. The curator watched that happen and does not need
// to be told the order cancelled itself.
if (isNull _target) exitWith {};

// Stalled means the deficit stopped closing with work still to do, and a truck out
// of stock is overwhelmingly the reason. Timed out means it was still closing, just
// not fast enough for SERVICE_TIMEOUT — a different thing, and one the engine
// should never produce for an ordinary order.
[
    QGVAR(report),
    [([LSTRING(MsgSupplyEmpty), LSTRING(MsgServiceIncomplete)] select _timedOut)],
    _curator
] call CBA_fnc_targetEvent;
