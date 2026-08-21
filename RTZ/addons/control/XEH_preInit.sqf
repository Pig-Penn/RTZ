#include "script_component.hpp"

ADDON = false;

PREP_RECOMPILE_START;
#include "XEH_PREP.hpp"
PREP_RECOMPILE_END;

// Config lookup behind FUNC(needsReload) — the reload action's condition, so it
// is hit once per class per right-click and never again. Filled lazily on the
// curator clients that open the menu; the machine that executes the order never
// reads it. The magazine-capacity half of that function's config reads is NOT
// here: rtz_supply and rtz_hud ask the identical question, so it lives in
// EFUNC(common,magazineCapacity). This one has no caller outside this component.
GVAR(weaponMagazines) = createHashMap;  // weapon class -> compatible magazines

#include "initSettings.inc.sqf"

ADDON = true;
