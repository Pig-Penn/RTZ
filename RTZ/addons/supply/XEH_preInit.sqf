#include "script_component.hpp"

ADDON = false;

PREP_RECOMPILE_START;
#include "XEH_PREP.hpp"
PREP_RECOMPILE_END;

// Config lookups are the expensive part of deciding what a vehicle can give, and
// the answer only depends on the class name. Filled lazily on first use, on
// every machine that either opens the context menu (curator clients) or runs the
// service loop (server). What it still NEEDS is the other half of that question,
// and its magazine-capacity cache is shared rather than kept here — rtz_control
// and rtz_hud ask it too, so it lives in EFUNC(common,magazineCapacity).
GVAR(capabilities) = createHashMap;   // vehicle class -> [repair, fuel, ammo]

#include "initSettings.inc.sqf"

ADDON = true;
