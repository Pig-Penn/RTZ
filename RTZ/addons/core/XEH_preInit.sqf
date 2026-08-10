#include "script_component.hpp"
ADDON = false;

PREP_RECOMPILE_START;
#include "XEH_PREP.hpp"
PREP_RECOMPILE_END;

#include "initSettings.inc.sqf"

// ─────────────────────────────────────────────────────────────────────────────
// EVERY MACHINE — profiling accumulator
// ─────────────────────────────────────────────────────────────────────────────
// sample id → [n, sumMs, maxMs, counterString] (the PERF_* indices in
// script_component.hpp). Above the hasInterface fork because the producers are on
// BOTH sides: the server samples the detection pass and the RC scan, clients sample
// each renderer. Created unconditionally and left empty while RTZ_perf is off — a
// nil read would abort whichever pass touched it first, and every producer is on a
// hot path where that means silently dropping the rest of the tick.
GVAR(perfAcc) = createHashMap;

// ─────────────────────────────────────────────────────────────────────────────
// SERVER — stream engine state
// ─────────────────────────────────────────────────────────────────────────────
// Must exist before FUNC(registerStream) is called from any component's postInit.
// The watcher registry itself is built by FUNC(streamServer).
if (isServer) then {
    GVAR(streams) = createHashMap;
};

if (!hasInterface) exitWith { ADDON = true };

// ─────────────────────────────────────────────────────────────────────────────
// CLIENT — engine state
// ─────────────────────────────────────────────────────────────────────────────
// All of it initialised HERE rather than in the functions that own it, because
// context-menu modifierFunctions run unconditionally while the displays that feed
// them are setting-gated: ZEN calls modifierFunction BEFORE condition
// (zen_context_menu_fnc_getActiveActions), so a display switched off in settings
// would otherwise have its action read a nil GVAR and throw on every menu open.

// Renderer registries, consumed by FUNC(frameLoop) every frame. Both empty means
// the frame loop exits after two array tests, without building a camera basis.
GVAR(worldRenderers) = [];
GVAR(uiRenderers)    = [];

// Selection, owned by FUNC(selectionPoll) and read by every display in every
// component:
//   selUnits    — selected infantry netIds, side-filtered and capped
//   selVehicles — selected vehicle netIds, capped
//   selHulls    — the whole selection resolved to distinct hulls, as OBJECTS
//   selOverflow — eligible units dropped by the cap, for the dialog header
//   reported    — the last subscription payload actually sent, the diff baseline
GVAR(selUnits)    = [];
GVAR(selVehicles) = [];
GVAR(selHulls)    = [];
GVAR(selOverflow) = 0;
GVAR(reported)    = [];

// Consumer demand, keyed by consumer id → [slices, wantsDetailed]
// (FUNC(setDemand)), where slices is a list of SRC_* constants. The selection
// slices are expensive to gather and pointless to stream when nothing is looking
// at them, so FUNC(buildReport) reports each one only while some display asks.
// This used to be a hardcoded read of two of rtz_hud's own display flags, which
// is a thing the shared engine should not know; a registry also makes the OR
// correct for free, where independent booleans would let the tags going dark
// switch the dialog's feed off under it.
GVAR(demands) = createHashMap;

// Overlay streams this curator has switched on.
GVAR(activeStreams) = [];

// Snapshot store for every stream using the default receiver
// (FUNC(receiveOverlay)): stream id → [entries, rxTime, dirty, refTime].
GVAR(streamData) = createHashMap;

// ── Stream presentation registries, all filled by FUNC(registerStream) ───────
//   streamReceivers — stream id → snapshot handler (FUNC(streamClient) dispatch)
//   streamSources   — stream id → SRC_* slice, so FUNC(selectionPoll) can hand an
//                     empty snapshot to exactly the receivers whose slice emptied
//   streamRenderers — stream id → world renderer, switched on with the overlay
//   streamSettings  — stream id → lowercased master setting, for the watchdog
//   streamLook      — stream id → [[toastHidden, toastShown],
//                                  [labelOff, labelOn], accentColour]
GVAR(streamReceivers) = createHashMap;
GVAR(streamSources)   = createHashMap;
GVAR(streamRenderers) = createHashMap;
GVAR(streamSettings)  = createHashMap;
GVAR(streamLook)      = createHashMap;

ADDON = true;
