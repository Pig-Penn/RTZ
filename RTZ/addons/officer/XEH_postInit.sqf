#include "script_component.hpp"

// Build stamp — logged on every machine so a stale/mismatched client PBO is visible
// in the RPT. This is a separate PBO from main; it can be stale independently.
diag_log text format ["[RTZ] officer postInit — version %1, machine [isServer=%2 hasInterface=%3 clientOwner=%4]",
    QUOTE(VERSION_STR), isServer, hasInterface, clientOwner];

// Setting-gated systems are deferred until CBA_settingsInitialized — reading a
// setting straight from postInit races the server→client settings sync (see
// spotting's XEH_postInit for the full rationale).
["CBA_settingsInitialized", {
    if (!GVAR(enable)) exitWith {};

    if (isServer) then {
        // Server-side registry of every RTZ area per module: curatorNetId ->
        // HashMap(areaId -> officerNetId). The engine has no getter for a module's
        // editing areas and the per-client tracking map dies with the session, so
        // this is what lets "clear" wipe orphans off a rejoined curator's module.
        GVAR(areasByCurator) = createHashMap;

        // Cross-addon contract (plain global, not GVAR — rtz_spotting reads it
        // without depending on rtz_officer): officerNetId -> zone radius, so a
        // spotted enemy officer's zone ring can ride his chevron payload
        // (see rtz_spotting's fnc_spottingSystem).
        RTZ_officerZoneRadiusMap = createHashMap;

        [QGVAR(applyArea), LINKFUNC(applyArea)] call CBA_fnc_addEventHandler;
    };

    // Per-client curator lifecycle + prune/follow loop (guards hasInterface itself)
    call FUNC(monitorAreas);
}] call CBA_fnc_addEventHandler;
