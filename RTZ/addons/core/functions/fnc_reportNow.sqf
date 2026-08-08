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
 *     to match FUNC(selectionPoll) EXACTLY.
 *
 * The payload rules now live in exactly one place for BOTH senders —
 * FUNC(buildReport) — so this function is only the send half: build, set the
 * baseline so the next poll tick does not repeat it, fire.
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
// carried into the demand fold as a non-boolean and throw. Constrained, it falls
// back to the default and the report is merely undetailed rather than broken.
params [["_forceDetailed", false, [false]]];

private _report = [_forceDetailed] call FUNC(buildReport);

// Copied, not aliased: the slice globals are replaced wholesale by the poll
// rather than mutated, but GVAR(activeStreams) is mutated IN PLACE by
// FUNC(toggleOverlay), and the baseline must not be able to follow a store this
// function does not own.
GVAR(reported) = +_report;

[QGVAR(watch), [player] + _report] call CBA_fnc_serverEvent;
