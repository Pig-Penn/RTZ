#include "script_component.hpp"

ADDON = false;

PREP_RECOMPILE_START;
#include "XEH_PREP.hpp"
PREP_RECOMPILE_END;

#include "initSettings.inc.sqf"

// Overlay client state, per overlay: master toggle (context action), last
// synced curator selection, watched unit netIds and the latest server
// snapshot. Initialized here so the context action, toggle and display halves
// can all assume the containers exist regardless of registration order.
if (hasInterface) then {
    GVAR(destEnabled) = false;
    GVAR(destSelection) = [];
    GVAR(destWatchedUnits) = createHashMap;
    GVAR(destDisplay) = [];

    GVAR(tgtEnabled) = false;
    GVAR(tgtSelection) = [];
    GVAR(tgtWatchedUnits) = createHashMap;
    GVAR(tgtDisplay) = [];
};

ADDON = true;
