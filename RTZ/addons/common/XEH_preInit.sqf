#include "script_component.hpp"

ADDON = false;

PREP_RECOMPILE_START;
#include "XEH_PREP.hpp"
PREP_RECOMPILE_END;

// Shared per-class config cache read by FUNC(classInfo) — created eagerly so
// every caller (spotting server loop, RC indicator) is safe on every machine.
GVAR(classInfoCache) = createHashMap;

// Magazine class → configured round count, read by FUNC(magazineCapacity).
// Eager for the same reason: its callers span the curator clients that open a
// context menu (rtz_control, rtz_supply) and the server that runs the gather
// loop (rtz_hud). Bounded by the number of magazine classes in CfgMagazines,
// not by unit count, so it needs no prune.
GVAR(magazineCapacities) = createHashMap;

#include "initSideColors.inc.sqf"
#include "initSettings.inc.sqf"

ADDON = true;
