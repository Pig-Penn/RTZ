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
// Must exist before the first stream tick reads it:
//   seatCntCache — vehicle class → total seat count (FUNC(gatherVehicleInfo))
//
// FUNC(gatherUnitInfo)'s magazine-capacity cache is NOT here. rtz_control and
// rtz_supply ask the identical per-class question, so it moved to
// EFUNC(common,magazineCapacity) — which is created unconditionally rather than
// behind this isServer gate, because those two callers run on curator clients.
if (isServer) then {
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
// the tags and the dialog rows all index by id.
GVAR(unitData)    = createHashMap;
GVAR(vehicleData) = createHashMap;

// Entity class → model-space bounding-box top, read by FUNC(tagAnchor) once per
// tagged entity per frame. CLIENT-side and not behind the isServer gate above,
// because the only thing that reads it is the draw pass. Bounded by the number of
// entity classes the mission actually spawns — not by unit count, and not by
// anything that churns — so like EFUNC(common,magazineCapacity) it needs no prune.
GVAR(modelTopCache) = createHashMap;

// ── Tag systems ─────────────────────────────────────────────────────────────
// One record per LIVE head-tag system (FUNC(startTagSystem)), holding its
// visibility, its built-entry cache, its dirty flag, its renderer and the slices
// it demands — see the TAG_* indices in script_component.hpp. A system whose
// master setting is off is simply absent, which is what replaced the `isNil`
// guard every consumer of the old per-system globals had to carry.
GVAR(tagSystems) = createHashMap;

// ONE settings watcher for every tag system, not one per system: registered here
// rather than at system start so it exists exactly once regardless of how many
// systems the settings leave switched on, and so a change arriving before any
// system starts finds an empty registry and does nothing.
//
// Two jobs. A setting whose name begins with a system's prefix (rtz_hud_tag… /
// rtz_hud_vtag…) invalidates that system's cache, so field toggles apply live. A
// change to a system's MASTER setting also syncs its runtime visibility, so
// switching it off hides the tags — and withdraws the stream demand behind them —
// immediately instead of waiting for a mission restart.
["CBA_SettingChanged", {
    params ["_name", "_value"];
    // Lowercased once here: CBA_SettingChanged is not guaranteed to report the
    // name in the case it was registered with, and every stored prefix/master is
    // already lowercased by FUNC(startTagSystem).
    private _lname = toLower _name;

    private _resync = false;
    {
        // _x: system id, _y: its record. Nothing below rebinds _x.
        _y params ["", "", "", "", "", "", "_prefix", "_master"];
        if ((_lname find _prefix) == 0) then { _y set [TAG_DIRTY, true] };
        if (_lname == _master) then {
            _y set [TAG_VISIBLE, _value];
            _resync = true;
        };
    } forEach GVAR(tagSystems);

    // Once, after the loop — not per system: FUNC(applyTagVisibility) syncs every
    // record anyway, so calling it inside would redo the whole registry per hit.
    if (_resync) then { call FUNC(applyTagVisibility) };
}] call CBA_fnc_addEventHandler;

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
// Set by FUNC(receiveUnitData) when a new snapshot lands; consumed by the selection
// dialog's tick, which otherwise rebuilds its whole row model four times a second
// whether or not anything changed. Same contract as a tag system's TAG_DIRTY, and
// a separate flag for the same reason the dialog declares its own demand: the
// dialog can be open with every tag system switched off.
GVAR(selRowsDirty) = true;

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
