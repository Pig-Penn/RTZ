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
        // without depending on rtz_officer): officerNetId -> [plantedCenter,
        // radius], so a spotted enemy officer's zone ring can ride his chevron
        // payload and be drawn where the area actually sits (see rtz_spotting's
        // fnc_spotCheck) — areas never move once planted, so the stored center
        // stays authoritative. Also the mutual-exclusion source FUNC(applyAura)
        // checks — an officer with an editing area cannot take a command aura —
        // so it exists even with editing areas disabled.
        RTZ_officerZoneMap = createHashMap;

        if (GVAR(enable)) then {
            [QGVAR(applyArea), LINKFUNC(applyArea)] call CBA_fnc_addEventHandler;

            // Areas are normally torn down by the placing client's
            // FUNC(monitorAreas) — including the wipe it runs when that client's
            // assigned curator changes. A client that DISCONNECTS never runs
            // either, so without this its areas stay registered here forever:
            // GVAR(areasByCurator) leaks, and RTZ_officerZoneMap keeps
            // feeding rtz_spotting zone rings for areas that no longer have an
            // owner to remove them. Resolve the module off allCurators rather
            // than the unit — allCurators is a handful of entries and the
            // assignment is what we actually need to reverse.
            addMissionEventHandler ["HandleDisconnect", {
                params ["_unit"];

                {
                    if (getAssignedCuratorUnit _x isEqualTo _unit) then {
                        ["clear", _x] call FUNC(applyArea);
                    };
                } forEach allCurators;

                // Never return true here — that would keep the disconnecting
                // player's body in the world
                false
            }];
        };

        if (GVAR(auraEnable)) then {
            // officerNetId -> aura radius. No stored position — the zone is
            // derived live from the officer each pass, so the aura follows him.
            GVAR(auras) = createHashMap;

            // groupNetId -> group, for every group held by ANY aura — the diff
            // baseline of FUNC(monitorAuras)
            GVAR(auraHeld) = createHashMap;

            [QGVAR(applyAura), LINKFUNC(applyAura)] call CBA_fnc_addEventHandler;
            call FUNC(monitorAuras);
        };
    };

    if (GVAR(auraEnable)) then {
        // allowFleeing needs group locality (server, HC, or a player leading AI),
        // so the effect receiver registers on EVERY machine — the monitor targets
        // the event at each group and CBA routes it to the owner.
        [QGVAR(applyAuraEffects), LINKFUNC(applyAuraEffects)] call CBA_fnc_addEventHandler;

        if (hasInterface) then {
            // Server → curator feedback for aura toggles: only the server owns the
            // aura registry, so only it knows whether a request actually applied.
            // (The GVAR(auraZones) map-ring mirror and its QGVAR(auraZone) handler
            // are NOT here — they must be up before CBA's JIP replay, see XEH_preInit.)
            [QGVAR(auraMsg), {(_this select 0) call zen_common_fnc_showMessage}] call CBA_fnc_addEventHandler;

            // Normally attached by FUNC(initCuratorDisplay) via the XEH DisplayLoad
            // event each time the curator display is created. If Zeus is somehow
            // already open when this (settings-deferred) block runs, attach now.
            private _curatorDisplay = findDisplay IDD_RSCDISPLAYCURATOR;
            if (!isNull _curatorDisplay) then {
                [_curatorDisplay] call FUNC(initCuratorDisplay);
            };
        };
    };

    if (GVAR(enable)) then {
        // Per-client curator lifecycle + prune loop (guards hasInterface itself)
        call FUNC(monitorAreas);
    };
}] call CBA_fnc_addEventHandler;
