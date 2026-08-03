#include "script_component.hpp"
/*
 * Author: Maxim
 * CLIENT. Re-send this curator's subscription to the server immediately, instead
 * of waiting for FUNC(selectionPoll)'s next tick.
 *
 * The one supported way to say "the server's picture of me is stale". A consumer
 * that has just changed what it wants — the selection info dialog opening and
 * asking for the leader intel, rtz_control resetting a squad and wanting the tags
 * to refresh on the spot — calls this rather than touching the engine's state.
 *
 * It exists because the alternative kept going wrong. There was no API, so call
 * sites hand-rolled it: build the payload, assign it to GVAR(reported) — the
 * poll's private diff baseline — and fire the subscribe event. That is three
 * chances to get one thing right, and it cost:
 *
 *   - rtz_hud's dialog spelled the event QGVAR(watch) in its OWN component, so it
 *     expanded to "rtz_hud_watch" and no handler existed. Because the same block
 *     had already written the baseline, the poll then compared its own report
 *     equal and suppressed the REAL send too, so the dialog's intel rows never
 *     filled on first open.
 *   - The same block re-derived the hull-slice gate, with a comment noting it had
 *     to match FUNC(selectionPoll) EXACTLY. Two copies of a rule that must agree
 *     is a rule that eventually will not: the moment they differ, the poll sees
 *     its own payload differ from the baseline and re-subscribes every tick.
 *
 * The payload is therefore built HERE, from the engine's own live state, by the
 * same rules the poll uses — callers no longer describe their subscription, they
 * only ask for it to be sent. Setting the baseline as it sends is what keeps the
 * next poll tick from re-sending the identical payload.
 *
 * Cheap enough to call on any user action: one event, and only when something
 * actually asked for it. It is NOT for per-frame or per-tick use — the poll
 * already covers steady state.
 *
 * Arguments:
 * 0: Force the expensive per-unit intel on for this report <BOOL> (default: read
 *    from the demand registry, i.e. whatever FUNC(setDemand) currently says)
 *
 * Return Value:
 * None
 *
 * Example:
 * [true] call rtz_core_fnc_reportNow
 *
 * Public: No
 */

if (!hasInterface) exitWith {};

// Type-constrained to BOOL: a caller reaching this with a bare `call` forwards its
// own _this, and a stray array landing on this parameter would otherwise be
// carried into the `if` below as a non-boolean and throw. Constrained, it falls
// back to the default and the report is merely undetailed rather than broken.
params [["_forceDetailed", false, [false]]];

// Same demand fold as FUNC(selectionPoll): the infantry slice is reported only
// while some consumer asks for it, and the intel flag only while one asks for
// that. A caller that has already registered its demand needs no override; the
// override exists for the one that registers it a few lines later.
private _wantUnits = false;
private _detailed  = _forceDetailed;
{
    _y params ["_u", "_d"];
    if (_u) then { _wantUnits = true };
    if (_d) then { _detailed  = true };
} forEach GVAR(demands);

// A forced-detailed report implies the infantry slice — asking for the intel
// without the units it describes would report an empty slice and gather nothing.
if (_forceDetailed) then { _wantUnits = true };

private _streams = GVAR(activeStreams);

// Slice gating, identical to the poll's: an unwanted slice is reported empty so
// the server neither gathers nor sends it, and the hull slice rides on an overlay
// actually being switched on.
private _report = [
    [[], GVAR(selUnits)] select _wantUnits,
    GVAR(selVehicles),
    [[], GVAR(selHulls)] select (_streams isNotEqualTo []),
    _streams,
    _detailed
];

// Copied, not aliased: GVAR(selUnits) and friends are replaced wholesale by the
// poll rather than mutated, but the baseline must not be able to follow a store
// this function does not own.
GVAR(reported) = +_report;

[QGVAR(watch), [player] + _report] call CBA_fnc_serverEvent;
