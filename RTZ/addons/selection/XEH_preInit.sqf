#include "script_component.hpp"
ADDON = false;
#include "XEH_PREP.hpp"

#include "initSettings.inc.sqf"

// Magazine-class → capacity config-read cache for the server-side gather
// (fnc_gatherUnitInfo), filled lazily per magazine class.
if (isServer) then { GVAR(magCapCache) = createHashMap };

// Display-label remap table (fnc_loadTagLabels — the one place to re-word tag
// text). Consumed only by the unit/vehicle tags, which are client-only, so
// it's built on interface machines.
if (hasInterface) then {
    GVAR(tagLabels) = createHashMap;
    call FUNC(loadTagLabels);
};

ADDON = true;
