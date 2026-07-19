#include "script_component.hpp"

ADDON = false;

PREP_RECOMPILE_START;
#include "XEH_PREP.hpp"
PREP_RECOMPILE_END;

// Classname -> cost category index, built lazily as classes are first priced
GVAR(categories) = createHashMap;

// Base cost in points, indexed by cost category
GVAR(baseCosts) = [
    COST_INFANTRY,
    COST_STATIC,
    COST_CAR,
    COST_APC,
    COST_TRACKED,
    COST_HELICOPTER,
    COST_PLANE,
    COST_BOAT,
    COST_TRUCK,
    COST_OFFICER
];

GVAR(toastPFH) = -1;
GVAR(toastClass) = "";

// Classname -> built-in cost in points, overriding the category default
#include "defaultCosts.inc.sqf"

#include "initSettings.inc.sqf"

ADDON = true;
