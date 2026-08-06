#include "script_component.hpp"

ADDON = false;

PREP_RECOMPILE_START;
#include "XEH_PREP.hpp"
PREP_RECOMPILE_END;

// Config lookups behind FUNC(needsReload) — the reload action's condition, so
// they are hit once per class per right-click and never again. Filled lazily on
// the curator clients that open the menu; the machine that executes the order
// never reads them.
GVAR(magazineSizes)   = createHashMap;  // magazine class -> full round count
GVAR(weaponMagazines) = createHashMap;  // weapon class -> compatible magazines

#include "initSettings.inc.sqf"

ADDON = true;
