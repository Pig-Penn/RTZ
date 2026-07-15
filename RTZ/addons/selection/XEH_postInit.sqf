#include "script_component.hpp"

// Build stamp — logged on every machine so a stale/mismatched client PBO is visible
// in the RPT. This is a separate PBO from main; it can be stale independently.
diag_log text format ["[RTZ] selection postInit — version %1, machine [isServer=%2 hasInterface=%3 clientOwner=%4]",
    QUOTE(VERSION_STR), isServer, hasInterface, clientOwner];

// Setting-gated systems are deferred until the CBA_settingsInitialized event:
// reading a setting straight from postInit races the server→client settings sync
// (nil read aborts postInit; a defensive default silently ignores a server-side
// "disabled"). CBA fires the event one frame after postInit, once every
// GVAR(enable*) holds the server's synced value.
// NOTE: CBA has no CBA_fnc_runAfterSettingsInit — that helper is ACE3/ZEN-only;
// calling the CBA_ name is a silent nil no-op.
// Both functions only register CBA event/PFH handlers and (client-side) UI
// handlers — no sleep/waitUntil — so they are `call`ed, not `spawn`ed: no reason
// to consume a scheduler slot, and the CBA_settingsInitialized handler is itself
// unscheduled.
["CBA_settingsInitialized", {
    if (GVAR(enableSelectionInfo)) then {
        [] call FUNC(selectionInfo);
    };

    // Vehicle data stream (server gather + client packet receipt) is shared by
    // the overlay cards and the vehicle tags — start it whenever either display
    // is enabled, ordered before both so their own QGVAR(selVehicleData)
    // handlers see this system's hashmap already filled. Both consumers also
    // need Selection Info: the selection poll that reports selected vehicles
    // (GVAR(selVehicleIds) / QGVAR(selVehicles)) lives in FUNC(selectionInfo),
    // so without it the stream would idle and the displays would stay blank.
    if (GVAR(enableSelectionInfo) && { GVAR(enableVehicleOverlay) || GVAR(enableVehicleTags) }) then {
        [] call FUNC(vehicleDataStream);
    };

    if (GVAR(enableSelectionInfo) && { GVAR(enableVehicleOverlay) }) then {
        [] call FUNC(vehicleOverlay);
    };

    // Unit head tags consume the data stream selectionInfo maintains — without
    // it they would never populate, so both switches must be on. Ordered after
    // FUNC(selectionInfo) so its QGVAR(selData) event handler (which fills the
    // hashmap) runs before the tags' cache-invalidation handler.
    if (GVAR(enableSelectionInfo) && { GVAR(enableUnitTags) }) then {
        [] call FUNC(unitTags);
    };

    // Vehicle tags consume the vehicle stream: the selection poll (in
    // selectionInfo) reports the selected vehicles and vehicleDataStream fills
    // GVAR(selVehicleData) (client) and runs the server gather — so both
    // switches must be on. Independent of GVAR(enableVehicleOverlay).
    if (GVAR(enableSelectionInfo) && { GVAR(enableVehicleTags) }) then {
        [] call FUNC(vehicleTags);
    };

    // Single "Draw Tags" context menu button drives whichever of the two tag
    // systems above are enabled — registered once, after both, so it only
    // exists when there's something for it to toggle.
    if (GVAR(enableSelectionInfo) && { GVAR(enableUnitTags) || GVAR(enableVehicleTags) }) then {
        [] call FUNC(tagsContext);
    };
}] call CBA_fnc_addEventHandler;
