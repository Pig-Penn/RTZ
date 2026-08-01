#include "script_component.hpp"

ADDON = false;

PREP_RECOMPILE_START;
#include "XEH_PREP.hpp"
PREP_RECOMPILE_END;

// Shared per-class config cache read by FUNC(classInfo) — created eagerly so
// every caller (spotting server loop, RC indicator) is safe on every machine.
GVAR(classInfoCache) = createHashMap;

// Memoised "magazine|weapon" countermeasure verdicts for
// FUNC(findCountermeasureWeapons), which the deploy-countermeasures context
// action evaluates on every right-click. Config-derived, so it never expires.
GVAR(cmWeaponCache) = createHashMap;

#include "initSideColors.inc.sqf"
#include "defaultSkills.inc.sqf"
#include "initSettings.inc.sqf"
#include "initKeybinds.inc.sqf"

ADDON = true;
