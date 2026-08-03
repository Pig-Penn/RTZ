#include "script_component.hpp"

ADDON = false;

PREP_RECOMPILE_START;
#include "XEH_PREP.hpp"
PREP_RECOMPILE_END;

// Memoised "magazine|weapon" countermeasure verdicts for
// FUNC(findCountermeasureWeapons), which the deploy-countermeasures context
// action evaluates on every right-click. Config-derived, so it never expires.
GVAR(cmWeaponCache) = createHashMap;

#include "initSettings.inc.sqf"

ADDON = true;
