#include "script_component.hpp"

ADDON = false;

PREP_RECOMPILE_START;
#include "XEH_PREP.hpp"
PREP_RECOMPILE_END;

// Bumped by every placement cost hint, so an older hint's pending fade-out
// leaves a newer one alone (see fnc_placementToast)
GVAR(toastToken) = 0;

// Classname -> cost category index, built lazily as classes are first priced
GVAR(categories) = createHashMap;

// CBA_missionTime of the next income payout, published by the server on every
// payout (see XEH_postInit) so a curator's own machine can count down to it.
// -1 means nothing is scheduled yet. Defined here rather than left nil because
// the income clock reads it every tick and a nil read aborts the whole
// enclosing script (docs/Knowledge Base/Gotchas.md §2)
GVAR(nextIncome) = -1;

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

// Classname -> cost in points, set by the mission to override anything built
// in (see fnc_registerCosts). Created here so a cost lookup never has to
// allocate a fallback map; preInit runs before any mission script, so a
// mission replacing the whole variable still works
GVAR(overrides) = createHashMap;

// Classname -> built-in cost in points, overriding the category default
#include "defaultCosts.inc.sqf"

#include "initSettings.inc.sqf"

ADDON = true;
