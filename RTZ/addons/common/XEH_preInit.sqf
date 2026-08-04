#include "script_component.hpp"

ADDON = false;

PREP_RECOMPILE_START;
#include "XEH_PREP.hpp"
PREP_RECOMPILE_END;

// Shared per-class config cache read by FUNC(classInfo) — created eagerly so
// every caller (spotting server loop, RC indicator) is safe on every machine.
GVAR(classInfoCache) = createHashMap;

// Per-class head selection offsets read by FUNC(headOffset). Bounded by the number
// of man classes in CfgVehicles, not by unit count, so it needs no prune.
GVAR(headOffsetCache) = createHashMap;

#include "initSideColors.inc.sqf"
#include "initSettings.inc.sqf"

ADDON = true;
