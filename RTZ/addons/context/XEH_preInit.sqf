#include "script_component.hpp"
ADDON = false;
#include "XEH_PREP.hpp"

#include "initSettings.inc.sqf"

// Destination-overlay client state. Initialized here so the context action,
// toggle and display halves can all assume the containers exist regardless of
// their registration order in postInit.
if (hasInterface) then {
    GVAR(destEnabled) = false;                  // master toggle (context action)
    GVAR(destSelection) = [];                   // last curator selection synced
    GVAR(destWatchedUnits) = createHashMap;     // unit netId -> true
    GVAR(destDisplay) = [];                     // latest server snapshot

    // Target-overlay client state — mirrors the destination containers above so
    // the target context action, toggle and display halves can all assume the
    // containers exist regardless of their registration order in postInit.
    GVAR(tgtEnabled) = false;                   // master toggle (context action)
    GVAR(tgtSelection) = [];                    // last curator selection synced
    GVAR(tgtWatchedUnits) = createHashMap;      // unit netId -> true
    GVAR(tgtDisplay) = [];                      // latest server snapshot
};

ADDON = true;
