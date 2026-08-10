#include "script_component.hpp"
/*
 * Author: Maxim
 * Flushes everything FUNC(perfSample) and FUNC(frameLoop) have accumulated to the
 * RPT every PERF_REPORT_INTERVAL seconds, then clears the accumulator so each line
 * summarises one window rather than the whole mission.
 *
 * Started unconditionally from XEH_postInit on EVERY machine — the producers are
 * split across the server (the detection pass, the RC scan) and the clients (the
 * renderers), and on a listen server, which is what this mod is run on (see
 * docs/Knowledge Base/Performance Audit Questions.md), both land here. That split is
 * itself the point: server-side and client-side costs are ADDITIVE on a host, so the
 * two halves have to be readable side by side in one log.
 *
 * Costs one getVariable every PERF_REPORT_INTERVAL seconds while switched off.
 *
 * Report shape — avg is what a steady state costs, max is what a spike costs, n says
 * how much of the window the sample covers (detection ticks vs. frames), and the
 * trailing counters say what the mission looked like while it was measured:
 *
 *   [RTZ perf] spotCheck            avg 4.81ms max 11.20ms n=3    sides=2 hostile=387 grps=54 chev=88
 *   [RTZ perf] collectSides         avg 1.90ms max 3.10ms  n=3    units=463 sides=2 reps=61
 *   [RTZ perf] rtz_spotting_spots   avg 1.93ms max 3.40ms  n=610
 *   [RTZ perf] --- fps 41.2 (min 33.1) ---
 *
 * A renderer id is whatever the display registered with FUNC(registerRenderer), so
 * the per-display breakdown names itself and a new display appears here for free.
 *
 * Arguments:
 * None
 *
 * Return Value:
 * None
 *
 * Example:
 * call rtz_core_fnc_perfReport
 *
 * Public: No
 */

[{
    if !(GETMVAR(RTZ_perf,false)) exitWith {
        // Switched off mid-window: drop whatever was collected rather than leaving it
        // to be printed, stale and mixed with a later window, whenever it comes back on.
        // Replaced, not cleared per key — producers hold no reference to the MAP, only
        // to the entry arrays inside it, and a producer's next sample re-creates its own.
        if (count GVAR(perfAcc) > 0) then { GVAR(perfAcc) = createHashMap };
    };

    if (count GVAR(perfAcc) == 0) exitWith {};

    // Collect-then-log, and replace the map at the end: a diag_log per entry inside the
    // walk is fine, but the map must not be mutated during it (see FUNC(pruneStores)'s
    // collect-then-delete rule) and a fresh map is cheaper than deleting every key.
    {
        _y params ["_n", "_sum", "_max", "_extra"];
        if (_n == 0) then { continue };

        diag_log text format ["[RTZ perf] %1 avg %2ms max %3ms n=%4 %5",
            _x, (_sum / _n) toFixed 3, _max toFixed 3, _n, _extra];
    } forEach GVAR(perfAcc);

    GVAR(perfAcc) = createHashMap;

    // Framerate last, as the line the timings above have to explain. hasInterface, not
    // isServer: diag_fps on a dedicated server is the simulation rate, which is a real
    // number but not the one anybody means by "the drop", and printing both under the
    // same word would confuse the two.
    if (hasInterface) then {
        diag_log text format ["[RTZ perf] --- fps %1 (min %2) ---", diag_fps toFixed 1, diag_fpsMin toFixed 1];
    };
}, PERF_REPORT_INTERVAL, []] call CBA_fnc_addPerFrameHandler;
