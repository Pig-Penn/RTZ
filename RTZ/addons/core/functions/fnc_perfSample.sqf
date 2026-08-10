#include "script_component.hpp"
/*
 * Author: Maxim
 * Records one timing sample under a named id, for the RTZ_perf profiling gate.
 *
 * Why this exists: nothing in this mod had ever been measured. Every cost in
 * docs/Knowledge Base/Performance Audit Questions.md was reasoned structurally —
 * which is enough to rank candidates and not enough to know which one is actually
 * costing frames on a 500-unit five-hour operation. This is the measurement.
 *
 * It also answers the one question the audit could not: whether a drop tracks UNIT
 * COUNT, CURATOR COUNT or HOW MUCH IS SPOTTED. Those are three separately timed
 * paths — EFUNC(spotting,collectSides) scales with unit count, the per-side loop in
 * EFUNC(spotting,spotCheck) scales with curator sides x hostiles, and
 * EFUNC(spotting,drawSpots) scales with how much is spotted — so timing them apart
 * distinguishes the three without guessing.
 *
 * Turning it on, from the debug console:
 *
 *     RTZ_perf = true;
 *
 * A plain missionNamespace flag read with GETMVAR, the same shape as the existing
 * RTZ_debug diagnostic. Local is enough on a listen server, where both halves run on
 * the one machine; `publicVariable "RTZ_perf"` reaches a dedicated server's producers.
 *
 * EVERY producer reads the flag ITSELF, once per pass, and skips building the sample
 * when it is off — this function is never the gate. With the flag off the whole
 * system costs one getVariable per producer per tick, and the report PFH below it.
 *
 * NOT for per-frame or per-entity callers. A `call` per renderer per frame is exactly
 * the cost this component exists to avoid, so FUNC(frameLoop) accumulates into
 * GVAR(perfAcc) inline instead, using the PERF_* indices from script_component.hpp.
 * Anything running a few times a second — a detection pass, a scan loop — should call
 * here.
 *
 * The entry is mutated in place, so the accumulator survives across ticks without a
 * re-`set`.
 *
 * Arguments:
 * 0: Sample id — the label the report prints, one per measured path <STRING>
 * 1: Elapsed milliseconds for this sample <NUMBER>
 * 2: Shape counters to print alongside the timing, already formatted. Build it
 *    ONLY under the caller's own flag test — it is a `format`, and an unguarded one
 *    on a per-tick path is the allocation CLAUDE.md rules out (optional, default "") <STRING>
 *
 * Return Value:
 * None
 *
 * Example:
 * ["spotCheck", (diag_tickTime - _t0) * 1000, format ["sides=%1", _n]] call rtz_core_fnc_perfSample
 *
 * Public: No
 */

params ["_id", "_ms", ["_extra", ""]];

private _entry = GVAR(perfAcc) get _id;
if (isNil "_entry") then {
    _entry = [0, 0, 0, ""];
    GVAR(perfAcc) set [_id, _entry];
};

_entry set [PERF_N,   (_entry select PERF_N) + 1];
_entry set [PERF_SUM, (_entry select PERF_SUM) + _ms];
if (_ms > (_entry select PERF_MAX)) then { _entry set [PERF_MAX, _ms] };
// Counters are a SNAPSHOT of the latest sample, not an average: they describe the
// mission's shape (how many hostiles, how many sides, how many chevrons), which is
// what the timing has to be read against. Averaging them would hide exactly the
// spikes worth seeing.
_entry set [PERF_EXTRA, _extra];
