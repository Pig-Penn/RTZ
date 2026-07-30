#include "script_component.hpp"

// ─────────────────────────────────────────────────────────────────────────────
// SERVER — data gathers, started unconditionally
// ─────────────────────────────────────────────────────────────────────────────
// These must NOT hang off the enable* settings. Every one of those is registered
// with isGlobal 0 (see initSettings.inc.sqf) — a PER-CLIENT display preference.
// Gating server-side code on one means a dedicated server evaluates the gate
// against its OWN copy of a client's preference: flip "Vehicle Tags" off in a
// server CBA settings file and every client's vehicle tags AND overlay cards go
// permanently blank, with nothing in the log to explain it.
// Both gathers subscribe on demand (clients report their selection only while
// something is looking at it) and idle at a single `count == 0` check otherwise,
// so running them always costs nothing when nobody is watching.
if (isServer) then {
    call FUNC(selectionGather);
    call FUNC(vehicleGather);
};

if (!hasInterface) exitWith {};

// ─────────────────────────────────────────────────────────────────────────────
// CLIENT — displays, gated on this client's own settings
// ─────────────────────────────────────────────────────────────────────────────
// Setting-gated systems are deferred until the CBA_settingsInitialized event:
// reading a setting straight from postInit races the server→client settings sync
// (nil read aborts postInit; a defensive default silently ignores a server-side
// "disabled"). CBA fires the event one frame after postInit, once every
// GVAR(enable*) holds the server's synced value.
// NOTE: CBA has no CBA_fnc_runAfterSettingsInit — that helper is ACE3/ZEN-only;
// calling the CBA_ name is a silent nil no-op.
// Every function below only registers CBA event/PFH handlers and UI handlers —
// no sleep/waitUntil — so they are `call`ed, not `spawn`ed: no reason to consume
// a scheduler slot, and the CBA_settingsInitialized handler is itself unscheduled.
["CBA_settingsInitialized", {
    // The selection poll owns GVAR(selCurrent) / GVAR(selVehicleIds) and is what
    // reports a selection to the server at all — every display below is dead
    // without it, hence the shared gate.
    if (!GVAR(enableSelectionInfo)) exitWith {};

    [] call FUNC(selectionInfo);

    // Vehicle packet receipt is shared by the overlay cards and the vehicle
    // tags — start it whenever either display is enabled, ordered before both so
    // their own QGVAR(selVehicleData) handlers see this system's hashmap already
    // filled.
    if (GVAR(enableVehicleOverlay) || GVAR(enableVehicleTags)) then {
        [] call FUNC(vehicleDataStream);
    };

    if (GVAR(enableVehicleOverlay)) then {
        [] call FUNC(vehicleOverlay);
    };

    // Unit head tags consume the infantry stream FUNC(selectionInfo) maintains.
    // Ordered after it so its QGVAR(selData) event handler (which fills the
    // hashmap) runs before the tags' cache-invalidation handler.
    if (GVAR(enableUnitTags)) then {
        [] call FUNC(unitTags);
    };

    // Vehicle tags consume the vehicle stream started above. Independent of
    // GVAR(enableVehicleOverlay) — either display can run without the other.
    if (GVAR(enableVehicleTags)) then {
        [] call FUNC(vehicleTags);
    };

    // Single "Draw Tags" context menu button drives whichever of the two tag
    // systems above are enabled — registered once, after both, so it only
    // exists when there's something for it to toggle.
    if (GVAR(enableUnitTags) || GVAR(enableVehicleTags)) then {
        [] call FUNC(tagsContext);
    };
}] call CBA_fnc_addEventHandler;
