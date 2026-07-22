#include "script_component.hpp"

ADDON = false;

PREP_RECOMPILE_START;
#include "XEH_PREP.hpp"
PREP_RECOMPILE_END;

// Config lookups are the expensive part of deciding what a vehicle can give and
// what it still needs, and both answers only depend on the class name. Both
// caches are filled lazily on first use and live on every machine that either
// opens the context menu (curator clients) or runs the service loop (server).
GVAR(capabilities) = createHashMap;   // vehicle class -> [repair, fuel, ammo]
GVAR(magazineSizes) = createHashMap;  // magazine class -> full round count

#include "initSettings.inc.sqf"

ADDON = true;
