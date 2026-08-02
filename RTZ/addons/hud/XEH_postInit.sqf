#include "script_component.hpp"

// ─────────────────────────────────────────────────────────────────────────────
// ENGINE — registered UNCONDITIONALLY on every machine
// ─────────────────────────────────────────────────────────────────────────────
// Neither half reads a setting to install itself, and both are free while
// nothing uses them: the client registers one early-exiting Draw3D handler plus
// a snapshot receiver, the server one subscribe receiver plus a PFH that bails
// on `count == 0` while nobody is watching.
//
// Gating the engine on a setting is a trap worth spelling out. Every enable*
// setting here is isGlobal 0 — a PER-CLIENT display preference — so a dedicated
// server would decide whether to feed its clients based on its OWN copy of a
// client's preference: flip "Vehicle Tags" off in a server CBA config and every
// client's tags AND cards go permanently blank, with nothing in the log to
// explain it. On the client side the context actions read their settings LIVE,
// so gating there surfaced a working-looking action on a machine that had never
// registered the machinery, and the toggle silently did nothing.
// `call`, not `spawn`: every body registers handlers and returns.
call FUNC(frameLoop);
call FUNC(streamClient);
call FUNC(streamServer);

// ─────────────────────────────────────────────────────────────────────────────
// SERVER — stream declarations
// ─────────────────────────────────────────────────────────────────────────────
// One line per data feed. The engine owns the registry, the poll loop, the diff
// and the push; a stream is just a gatherer, the selection slice it reads, and
// the setting naming its cadence. Registered unconditionally for the same reason
// the engine is — a stream nobody subscribes to never runs.
if (isServer) then {
    [STREAM_UNIT, LINKFUNC(gatherUnitInfo),    SRC_UNITS, QGVAR(gatherInterval), 0.3] call FUNC(registerStream);
    [STREAM_VEH,  LINKFUNC(gatherVehicleInfo), SRC_VEHS,  QGVAR(gatherInterval), 0.3] call FUNC(registerStream);
    [STREAM_DEST, LINKFUNC(gatherDestination), SRC_HULLS, QGVAR(pollInterval),   2  ] call FUNC(registerStream);
    [STREAM_TGT,  LINKFUNC(gatherTarget),      SRC_HULLS, QGVAR(pollInterval),   2  ] call FUNC(registerStream);
};

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
// calling the CBA_ name is a silent nil no-op (docs/Gotchas.md §4).
// Every function below only registers handlers and returns — no sleep/waitUntil —
// so they are `call`ed, not `spawn`ed.
["CBA_settingsInitialized", {
    // The selection poll owns GVAR(selUnits) / GVAR(selVehicles) / GVAR(selHulls)
    // and is what subscribes to the server at all — every display below is dead
    // without it, hence the shared gate. It also registers the info dialog's
    // context action, whose show-condition reads that same selection.
    if (!GVAR(enableSelectionInfo)) exitWith {};

    call FUNC(selectionPoll);

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
