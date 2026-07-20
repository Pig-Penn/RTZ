#include "script_component.hpp"

ADDON = false;

PREP_RECOMPILE_START;
#include "XEH_PREP.hpp"
PREP_RECOMPILE_END;

GVAR(units) = [];
GVAR(draw) = -1;
GVAR(magazineCapacities) = createHashMap;

#include "initSettings.inc.sqf"

ADDON = true;
