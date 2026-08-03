#include "script_component.hpp"
ADDON = false;

PREP_RECOMPILE_START;
#include "XEH_PREP.hpp"
PREP_RECOMPILE_END;

#include "initSettings.inc.sqf"

// ─────────────────────────────────────────────────────────────────────────────
// SERVER — stream engine state
// ─────────────────────────────────────────────────────────────────────────────
// GVAR(streams) must exist before FUNC(registerStream) is called from postInit,
// and the gather caches before the first tick reads them:
//   magCapCache  — magazine class → capacity (FUNC(gatherUnitInfo))
//   seatCntCache — vehicle class → total seat count (FUNC(gatherVehicleInfo))
if (isServer) then {
    GVAR(streams)      = createHashMap;
    GVAR(magCapCache)  = createHashMap;
    GVAR(seatCntCache) = createHashMap;
};

if (!hasInterface) exitWith { ADDON = true };

// ─────────────────────────────────────────────────────────────────────────────
// CLIENT — pipeline state
// ─────────────────────────────────────────────────────────────────────────────
// All of this is initialized HERE rather than in the functions that own it,
// because the context-menu modifierFunctions run unconditionally while those
// functions are setting-gated: ZEN calls modifierFunction BEFORE condition
// (zen_context_menu_fnc_getActiveActions), so a display switched off in settings
// would otherwise have its action read a nil GVAR and throw on every menu open.

// Renderer registries, consumed by FUNC(frameLoop) every frame. Both empty means
// the frame loop exits after two array tests, without building a camera basis.
GVAR(worldRenderers) = [];
GVAR(uiRenderers)    = [];

// Selection, owned by FUNC(selectionPoll) and read by every display:
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

// Snapshot stores, filled by FUNC(streamClient):
//   unitData    — netId → infantry packet
//   vehicleData — netId → vehicle packet
//   streamData  — stream id → [entries, rxTime, dirty, refTime] (overlay feeds)
GVAR(unitData)    = createHashMap;
GVAR(vehicleData) = createHashMap;
GVAR(streamData)  = createHashMap;

// Dirty flags — set on receipt, cleared by the consumer once it has rebuilt.
GVAR(unitTagsDirty)    = true;
GVAR(vehicleTagsDirty) = true;
GVAR(vehicleDataDirty) = true;

// Overlay streams this curator has switched on.
GVAR(activeStreams) = [];

// ── Stream presentation registries, all filled by FUNC(registerStream) ───────
// These used to be literal tables naming STREAM_DEST and STREAM_TGT here, which
// is what made the shared engine know the ids of this addon's own displays — and
// left a stream declared elsewhere (rtz_supply) writing into them by hand from its
// own postInit. Empty here, populated by each stream's declaration, so the engine
// carries no display knowledge and an external stream completes itself.
//   streamReceivers — stream id → snapshot handler (FUNC(streamClient) dispatch)
//   streamRenderers — stream id → world renderer, switched on with the overlay
//   streamSettings  — stream id → lowercased master setting, for the watchdog
//   streamLook      — stream id → [[toastHidden, toastShown],
//                                  [labelOff, labelOn], accentColour]
GVAR(streamReceivers) = createHashMap;
GVAR(streamRenderers) = createHashMap;
GVAR(streamSettings)  = createHashMap;
GVAR(streamLook)      = createHashMap;

// Engine planningMode → short label (FUNC(drawDestination)). Keys are normalized
// (uppercase, spaces stripped) because the engine reports e.g. "LEADER PLANNED"
// at runtime while the wiki documents "LeaderPlanned" (docs/Gotchas.md §4).
// VEHICLEPLANNED is the mode every driving vehicle reports — without it they all
// showed the raw engine string. DONOTPLAN means "not moving", which is a plan of
// its own, not a direct one.
GVAR(destModeLabels) = createHashMapFromArray [
    ["LEADERPLANNED",      LLSTRING(ModePlanned)],
    ["LEADERDIRECT",       LLSTRING(ModeDirect)],
    ["VEHICLEPLANNED",     LLSTRING(ModePlanned)],
    ["FORMATIONPLANNED",   LLSTRING(ModeFormation)],
    ["DONOTPLANFORMATION", LLSTRING(ModeFormation)],
    ["DONOTPLAN",          LLSTRING(ModeHolding)]
];

// True while the selection info dialog is open — guards against stacking
// duplicates AND gates what FUNC(selectionPoll) reports to the server.
GVAR(dialogOpen) = false;

// Display-label tables. Both hold LOCALIZED text: the packets carry stable wire
// tokens (FLAG_*, STATUS_*, LAMBS' own task/tactic strings) and these turn them
// into something a curator should read — resolved once here, never per frame.
GVAR(tagLabels) = createHashMap;
call FUNC(loadTagLabels);

// LAMBS danger causes, indexed by dangerType + 2. Blank keys stay blank ("No
// Danger" is deliberately not labelled — see DANGER_LABEL_KEYS).
GVAR(dangerLabels) = DANGER_LABEL_KEYS apply {
    ["", localize _x] select (_x != "")
};

ADDON = true;
