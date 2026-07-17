#include "script_component.hpp"

// Setting-gated systems are deferred until CBA_settingsInitialized — reading a
// setting straight from postInit races the server→client settings sync (see
// spotting's XEH_postInit for the full rationale).
["CBA_settingsInitialized", {
    if (isServer) then {
        // Server-side registry of every RTZ area per module: curatorNetId ->
        // HashMap(areaId -> officerNetId). The engine has no getter for a module's
        // editing areas and the per-client tracking map dies with the session, so
        // this is what lets "clear" wipe orphans off a rejoined curator's module.
        GVAR(areasByCurator) = createHashMap;

        // Cross-addon contract (plain global, not GVAR — rtz_spotting reads it
        // without depending on rtz_officer): officerNetId -> zone radius, so a
        // spotted enemy officer's zone ring can ride his chevron payload
        // (see rtz_spotting's fnc_spotCheck). Also the mutual-exclusion source
        // FUNC(applyAura) checks — an officer with an editing area cannot take a
        // command aura — so it exists even with editing areas disabled.
        RTZ_officerZoneRadiusMap = createHashMap;

        if (GVAR(enable)) then {
            [QGVAR(applyArea), LINKFUNC(applyArea)] call CBA_fnc_addEventHandler;
        };

        if (GVAR(auraEnable)) then {
            // officerNetId -> aura radius. No stored position — the zone is
            // derived live from the officer each pass, so the aura follows him.
            GVAR(auras) = createHashMap;

            // Groups currently held by ANY aura — the diff baseline of FUNC(monitorAuras)
            GVAR(auraHeld) = [];

            [QGVAR(applyAura), LINKFUNC(applyAura)] call CBA_fnc_addEventHandler;
            call FUNC(monitorAuras);
        };
    };

    if (GVAR(auraEnable)) then {
        // allowFleeing needs group locality (server, HC, or a player leading AI),
        // so the effect receiver registers on EVERY machine — the monitor targets
        // the event at each group and CBA routes it to the owner.
        [QGVAR(auraApply), LINKFUNC(auraApply)] call CBA_fnc_addEventHandler;

        // Server → curator feedback for aura toggles: only the server owns the
        // aura registry, so only it knows whether a request actually applied.
        if (hasInterface) then {
            [QGVAR(auraMsg), {(_this select 0) call zen_common_fnc_showMessage}] call CBA_fnc_addEventHandler;
        };
    };

    if (GVAR(enable)) then {
        // Per-client curator lifecycle + prune/follow loop (guards hasInterface itself)
        call FUNC(monitorAreas);
    };
}] call CBA_fnc_addEventHandler;
