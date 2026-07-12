#include "script_component.hpp"

ADDON = false;

PREP_RECOMPILE_START;
#include "XEH_PREP.hpp"
PREP_RECOMPILE_END;

// Classname -> cost category index, built lazily as classes are first priced
GVAR(categories) = createHashMap;

#include "initSettings.inc.sqf"

ADDON = true;
