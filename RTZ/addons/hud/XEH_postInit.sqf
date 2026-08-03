#include "script_component.hpp"

// The frame loop, the stream engine and the selection poll are NOT started here —
// rtz_core owns and starts them. This component declares streams on that engine
// and registers renderers with it, exactly as rtz_mine, rtz_spotting and
// rtz_supply do.

// ─────────────────────────────────────────────────────────────────────────────
// STREAM DECLARATIONS — one block per data feed, both halves
// ─────────────────────────────────────────────────────────────────────────────
// A stream is its gatherer, the selection slice it reads, the setting naming its
// cadence, where its snapshots land, and — for a toggleable overlay — its
// renderer and its wording. The engine owns the registry, the poll loop, the
// diff, the push and the dispatch.
//
// Called on EVERY machine, not under isServer: EFUNC(core,registerStream)
// self-gates each half, and the CLIENT half is the point. Registered
// unconditionally, because a stream nobody subscribes to never runs — and because
// gating registration on a per-client display setting would mean a dedicated
// server deciding whether to feed its clients from its own copy of their
// preference (flip "Vehicle Tags" off in a server CBA config and every client's
// tags AND cards go blank, with nothing in the log to explain it).
//
// The two selection feeds are always-on and declare no overlay bundle; the two
// AI-state overlays are toggleable and take the engine's default raw-store
// receiver. Cadence: the selection feeds ride this component's own gatherInterval,
// the overlays the engine's shared pollInterval — they read far heavier state
// (expectedDestination / targetKnowledge) and are useful an order of magnitude
// slower.
[
    STREAM_UNIT, LINKFUNC(gatherUnitInfo), SRC_UNITS, QGVAR(gatherInterval), 0.3,
    LINKFUNC(receiveUnitData)
] call EFUNC(core,registerStream);

[
    STREAM_VEH, LINKFUNC(gatherVehicleInfo), SRC_VEHS, QGVAR(gatherInterval), 0.3,
    LINKFUNC(receiveVehicleData)
] call EFUNC(core,registerStream);

[
    STREAM_DEST, LINKFUNC(gatherDestination), SRC_HULLS, QEGVAR(core,pollInterval), 2,
    ELINKFUNC(core,receiveOverlay),
    [
        LINKFUNC(drawDestination),
        QGVAR(enableDestinationDisplay),
        [LLSTRING(MsgDestinationsHidden), LLSTRING(MsgDestinationsShown)],
        [LLSTRING(ActionDrawDestinations), LLSTRING(ActionHideDestinations)],
        COLOR_DEST
    ]
] call EFUNC(core,registerStream);

[
    STREAM_TGT, LINKFUNC(gatherTarget), SRC_HULLS, QEGVAR(core,pollInterval), 2,
    ELINKFUNC(core,receiveOverlay),
    [
        LINKFUNC(drawTarget),
        QGVAR(enableTargetDisplay),
        [LLSTRING(MsgTargetsHidden), LLSTRING(MsgTargetsShown)],
        [LLSTRING(ActionDrawTargets), LLSTRING(ActionHideTargets)],
        COLOR_TGT
    ]
] call EFUNC(core,registerStream);

if (!hasInterface) exitWith {};

// ─────────────────────────────────────────────────────────────────────────────
// CLIENT — displays, gated on this client's own settings
// ─────────────────────────────────────────────────────────────────────────────
// Setting-gated systems are deferred until the CBA_settingsInitialized event:
// reading a setting straight from postInit races the server→client settings sync
// (a nil read aborts the rest of postInit; a defensive default silently ignores a
// server-side "disabled"). CBA fires the event one frame after postInit, once
// every GVAR(enable*) holds the server's synced value.
// NOTE: CBA has no CBA_fnc_runAfterSettingsInit — that helper is ACE3/ZEN-only;
// calling the CBA_ name is a silent nil no-op (docs/Knowledge Base/Gotchas.md §4).
// Every function below only registers handlers and returns — no sleep/waitUntil —
// so they are `call`ed, not `spawn`ed.
["CBA_settingsInitialized", {
    // Each display below is gated on ITS OWN master switch, and the four switches
    // are independent CBA settings a curator sets separately. This block used to
    // open with a bare `if (!GVAR(enableSelectionInfo)) exitWith {}` — which is not
    // scoped to the dialog it reads like: `exitWith` here leaves the whole handler,
    // so switching "Selection Info" off silently took the unit tags, the vehicle
    // tags, the vehicle cards AND the shared "Draw Tags" toggle down with it. The
    // guard belongs around the one action it governs.
    if (GVAR(enableSelectionInfo)) then {
        // Selection info dialog: its own ZEN action. This used to live inside the
        // engine's selection poll, on the reasoning that the poll owned the selection
        // the show-condition reads — but the action opens THIS component's dialog, and
        // leaving it in the engine is what made an addon-agnostic poll carry one
        // addon's menu entry.
        private _action = [
            "RTZ_ViewSelInfo",
            LLSTRING(ActionBehavior),
            ["\a3\ui_f\data\igui\cfg\simpletasks\types\intel_ca.paa", [1, 1, 1, 1]],
            { call FUNC(openSelectionInfo) },
            // Show-condition: ZEN lists the action when this returns true, so it must
            // be true when units ARE selected (it was once inverted, which hid the
            // action exactly when it had something to show).
            { EGVAR(core,selUnits) isNotEqualTo [] },
            [],
            {},
            {}
        ] call zen_context_menu_fnc_createAction;

        [_action, ["RTZ_Control"], 5] call zen_context_menu_fnc_addAction;
    };

    if (GVAR(enableVehicleOverlay)) then {
        call FUNC(vehicleOverlay);
    };

    if (GVAR(enableUnitTags)) then {
        call FUNC(unitTags);
    };

    // Independent of GVAR(enableVehicleOverlay) — either vehicle display can run
    // without the other; they share the STREAM_VEH packets.
    if (GVAR(enableVehicleTags)) then {
        call FUNC(vehicleTags);
    };

    // Single "Draw Tags" context menu button drives whichever of the two tag
    // systems above are enabled — registered once, after both, so it only exists
    // when there is something for it to toggle.
    if (GVAR(enableUnitTags) || GVAR(enableVehicleTags)) then {
        call FUNC(tagsContext);
    };
}] call CBA_fnc_addEventHandler;
