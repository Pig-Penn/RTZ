#include "script_component.hpp"
ADDON = false;

PREP_RECOMPILE_START;
#include "XEH_PREP.hpp"
PREP_RECOMPILE_END;

#include "initSettings.inc.sqf"

// NOTE: the engine's own state — renderer registries, the selection slices, the
// stream registries, the overlay snapshot store — is NOT here. It belongs to
// rtz_core, which owns the frame loop and the stream engine; this component is one
// of its consumers, like rtz_mine, rtz_spotting and rtz_supply. What remains below
// is this component's DISPLAY state only.

// ─────────────────────────────────────────────────────────────────────────────
// SERVER — gather caches
// ─────────────────────────────────────────────────────────────────────────────
// Must exist before the first stream tick reads them:
//   magCapCache  — magazine class → capacity (FUNC(gatherUnitInfo))
//   seatCntCache — vehicle class → total seat count (FUNC(gatherVehicleInfo))
if (isServer) then {
    GVAR(magCapCache)  = createHashMap;
    GVAR(seatCntCache) = createHashMap;
};

if (!hasInterface) exitWith { ADDON = true };

// ─────────────────────────────────────────────────────────────────────────────
// CLIENT — display state
// ─────────────────────────────────────────────────────────────────────────────
// All of this is initialized HERE rather than in the functions that own it,
// because the context-menu modifierFunctions run unconditionally while those
// functions are setting-gated: ZEN calls modifierFunction BEFORE condition
// (zen_context_menu_fnc_getActiveActions), so a display switched off in settings
// would otherwise have its action read a nil GVAR and throw on every menu open.

// Snapshot stores, filled by this component's own stream receivers
// (FUNC(receiveUnitData) / FUNC(receiveVehicleData)) — netId → packet, because
// the tags, cards and dialog rows all index by id.
GVAR(unitData)    = createHashMap;
GVAR(vehicleData) = createHashMap;

// Dirty flags — set on receipt, cleared by the consumer once it has rebuilt.
GVAR(unitTagsDirty)    = true;
GVAR(vehicleTagsDirty) = true;
GVAR(vehicleDataDirty) = true;

// Engine planningMode → short label (FUNC(drawDestination)). Keys are normalized
// (uppercase, spaces stripped) because the engine reports e.g. "LEADER PLANNED"
// at runtime while the wiki documents "LeaderPlanned" (docs/Knowledge Base/Gotchas.md §4).
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
// duplicates. It no longer gates what the engine reports: the dialog declares that
// through EFUNC(core,setDemand) instead, so the engine does not have to read one
// of this component's globals by name to know whether anyone wants the feed.
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
