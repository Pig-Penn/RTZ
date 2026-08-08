#include "script_component.hpp"
/*
 * Author: Maxim
 * CLIENT. Builds this curator's subscription payload from the engine's own live
 * state — the ONE place the "what does the server need to hear from me" rules
 * live.
 *
 * It exists because those rules had two copies. FUNC(selectionPoll) folded the
 * demand registry and assembled the payload on its tick; FUNC(reportNow) folded
 * the same registry and assembled the same payload on demand, with a comment on
 * the hull gate warning that it had to match the poll EXACTLY. Two copies of a
 * rule that must agree is a rule that eventually will not — and when they differ
 * the failure is silent and expensive: the poll finds its own payload differs
 * from the baseline the other one wrote and re-subscribes on every single tick,
 * for the rest of the mission.
 *
 * The rules, in one place:
 *   units    — reported only while some consumer demands SRC_UNITS
 *   vehicles — reported only while some consumer demands SRC_VEHS
 *   hulls    — reported only while at least one overlay stream is switched on;
 *              gated on GVAR(activeStreams) rather than on demand, because that
 *              IS the hull demand (see script_macros_core.hpp)
 *   detailed — reported while some consumer asks for the intel, or the caller
 *              forces it
 *
 * A report with nothing in any slice unsubscribes this curator server-side.
 *
 * Callers do NOT write GVAR(reported) — that is the poll's private diff baseline.
 * FUNC(reportNow) is the supported way to send one immediately.
 *
 * Arguments:
 * 0: Force the expensive per-unit intel on for this report <BOOL> (default: read
 *    from the demand registry, i.e. whatever FUNC(setDemand) currently says)
 *
 * Return Value:
 * Subscription payload, [units, vehicles, hulls, streams, detailed] <ARRAY>
 *
 * Example:
 * private _report = [true] call rtz_core_fnc_buildReport
 *
 * Public: No
 */

params [["_forceDetailed", false, [false]]];

private _wantUnits = false;
private _wantVehs  = false;
private _detailed  = _forceDetailed;

{
    // _x: consumer id, _y: [slices, wantsDetailed]
    _y params ["_slices", "_d"];
    if (SRC_UNITS in _slices) then { _wantUnits = true };
    if (SRC_VEHS  in _slices) then { _wantVehs  = true };
    if (_d) then { _detailed = true };
} forEach GVAR(demands);

// A forced-detailed report implies the infantry slice — asking for the intel
// without the units it describes would report an empty slice and gather nothing.
// The override exists for the consumer that registers its demand a few lines
// after asking for the report (rtz_hud's selection dialog).
if (_forceDetailed) then { _wantUnits = true };

private _streams = GVAR(activeStreams);

// Empty out the slices no active consumer wants, so the server neither gathers
// nor sends them.
[
    [[], GVAR(selUnits)]    select _wantUnits,
    [[], GVAR(selVehicles)] select _wantVehs,
    [[], GVAR(selHulls)]    select (_streams isNotEqualTo []),
    _streams,
    _detailed
]
