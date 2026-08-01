#include "script_component.hpp"

ADDON = false;

PREP_RECOMPILE_START;
#include "XEH_PREP.hpp"
PREP_RECOMPILE_END;

#include "initSettings.inc.sqf"

// Areas added by THIS client's curator: officerNetId -> [areaId]. The centre and
// radius are not tracked — an area never moves after it is planted, so nothing
// ever needs to re-read them (see FUNC(monitorAreas)).
// Created eagerly so every reader (toggle, modifier) is safe before the monitor starts.
GVAR(areas) = createHashMap;
GVAR(nextAreaId) = AREA_ID_BASE;

// Post-removal placement lock, THIS client only: officerNetId -> CBA_missionTime
// an area may next be added. See FUNC(isOnCooldown).
GVAR(cooldowns) = createHashMap;

// className -> isOfficer verdict, so the string scan runs once per class (see FUNC(isOfficer))
GVAR(classCache) = createHashMap;

// Last FUNC(getOfficers) result, memoised for one frame: [frame, objects, officers].
// See that function for why a single frame is the right window.
GVAR(officerCache) = [-1, [], []];

if (hasInterface) then {
    // Client-side mirror of the server's GVAR(auras) for the map ring overlay:
    // officerNetId -> [officer, radius]. Kept in sync by QGVAR(auraZone)
    // broadcasts from FUNC(applyAura) (toggle) and FUNC(monitorAuras)
    // (death/delete prune); drawn by FUNC(initCuratorDisplay).
    //
    // Mirror and handler are set up HERE rather than in the settings-deferred
    // XEH_postInit block, even though everything else aura-related waits for
    // GVAR(auraEnable). CBA replays its JIP event stack one frame after
    // postInit, but CBA_settingsInitialized only fires once the server's
    // settings have reached the client — later than that for a JIP client. A
    // handler registered on the setting would miss the replayed QGVAR(auraZone)
    // adds, and a joiner would never draw a ring for an aura that was switched
    // on before they connected. Registering unconditionally costs one empty
    // hashmap and one never-fired handler when the aura system is off.
    GVAR(auraZones) = createHashMap;

    [QGVAR(auraZone), {
        params ["_mode", "_key", ["_officer", objNull], ["_radius", 0]];

        if (_mode isEqualTo "add") then {
            // A JIP replay fires a frame after postInit, early enough that the
            // broadcast officer reference can still be null here. The entry is
            // keyed by his netId, so resolve from that instead; if even that is
            // too early, FUNC(initCuratorDisplay) retries on first draw.
            if (isNull _officer) then {_officer = objectFromNetId _key};

            GVAR(auraZones) set [_key, [_officer, _radius]];
        } else {
            GVAR(auraZones) deleteAt _key;
        };
    }] call CBA_fnc_addEventHandler;
};

ADDON = true;
