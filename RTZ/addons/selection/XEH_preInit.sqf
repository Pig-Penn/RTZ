#include "script_component.hpp"
ADDON = false;
#include "XEH_PREP.hpp"

#include "initSettings.inc.sqf"

// Server-side gather caches, filled lazily: magazine class → capacity
// (fnc_gatherUnitInfo) and vehicle class → total seat count
// (fnc_vehicleDataStream).
if (isServer) then {
    GVAR(magCapCache)   = createHashMap;
    GVAR(seatCntCache)  = createHashMap;
};

// Display-label remap table (fnc_loadTagLabels — the one place to re-word tag
// text). Consumed only by the unit/vehicle tags, which are client-only, so
// it's built on interface machines.
if (hasInterface) then {
    GVAR(tagLabels) = createHashMap;
    call FUNC(loadTagLabels);
};

ADDON = true;
