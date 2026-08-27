#include "script_component.hpp"
/*
 * Author: Maxim
 * SERVER handler body for QGVAR(rcClaim) (registered in XEH_postInit). Arbitrates which
 * ONE machine rebuilds a released unit, and answers the winner with QGVAR(rcRebuildAt).
 *
 * WHY AN ARBITER IS NEEDED. FUNC(rcReset) dispatches globally and every machine waits
 * for `local _unit` (FUNC(rcResetApply)) — but `local` is a LAGGING indicator during the
 * handover a release starts, and it lags in the direction that hurts. `remoteControl`
 * parks the unit on the controller's machine, so at release time `local` is still true
 * THERE, and stays true until the handover lands elsewhere. The ex-controller's wait
 * therefore settles on the first frame it is evaluated, while the machine the unit
 * actually lands on settles a round trip later — with the original still alive, still
 * eligible, and still not deleted. BOTH ran the rebuild.
 *
 * That is only visible when the two are different machines, which is why it survived
 * review: a curator releasing a unit HE placed is releasing one that was already local
 * to him, so there is no handover and no second claimant. It takes a curator releasing
 * somebody else's unit — or a mission-placed one — and then the release yields TWO
 * replacements for one unit, one of them a duplicate nothing owns.
 *
 * `local` cannot be fixed in place, because no machine can observe a handover it is not
 * the destination of. The server can: `owner` is authoritative there, and events arrive
 * in an order. So the wait stays exactly as it was — it is still the right way to find a
 * CANDIDATE — and the server picks the winner among them.
 *
 * TWO GATES, and they do different jobs:
 *   owner test — refuses a requester whose locality has already lapsed WITHOUT spending
 *     the claim, so a stale candidate cannot lock out the machine that really owns the
 *     unit. This is the gate that makes the arbitration safe to lose.
 *   claim registry — makes the grant one-shot. The owner test alone would pass BOTH
 *     claimants, just at different times: each is genuinely the owner when it asks.
 *
 * The registry is bounded by pruning on write rather than by a cap: entries are one per
 * release and lapse after RC_CLAIM_WINDOW, so on a multi-hour operation it holds the
 * handful of releases in the last few seconds and nothing else. Collected then deleted,
 * never deleted mid-forEach.
 *
 * Arguments:
 * 0: Released unit <OBJECT>
 * 1: Requesting machine's client ID <NUMBER> - its own clientOwner
 *
 * Return Value:
 * None
 *
 * Example:
 * [_unit, clientOwner] call rtz_control_fnc_rcClaim
 *
 * Public: No
 */

// Both arguments are type-checked: this arrives over a CLIENT-fired server event, so
// `isNull` and the owner compare below are not the client's to promise. Same reason
// EFUNC(core,streamServer) type-checks its own subscribe payload.
params [["_unit", objNull, [objNull]], ["_requester", -1, [0]]];

if (isNull _unit) exitWith {};

// The requester lost the unit between asking and being heard. Silent, and deliberately
// NOT a claim: the real owner's request is still to come.
if (owner _unit != _requester) exitWith {};

private _now = CBA_missionTime;

private _stale = [];
{
    if (_now - _y > RC_CLAIM_WINDOW) then { _stale pushBack _x };
} forEach GVAR(rcClaims);
{ GVAR(rcClaims) deleteAt _x } forEach _stale;

private _key = netId _unit;
if (_key in GVAR(rcClaims)) exitWith {};

GVAR(rcClaims) set [_key, _now];

// By client ID, not CBA_fnc_targetEvent: that one re-derives the target from `local`,
// which is the very reading this function exists to stop trusting.
[QGVAR(rcRebuildAt), [_unit], _requester] call CBA_fnc_ownerEvent;
