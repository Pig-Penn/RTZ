#include "script_component.hpp"

ADDON = false;

PREP_RECOMPILE_START;
#include "XEH_PREP.hpp"
PREP_RECOMPILE_END;

// Initialised HERE rather than behind CBA_settingsInitialized: FUNC(canStrike)
// reads it from a ZEN context CONDITION, which is evaluated on every context-menu
// open from the first frame the curator display exists. A nil read there is
// "Undefined variable" spam in the RPT on every right-click.
GVAR(enabled) = false;

// Config-derived weapon classification, memoised per vehicle CLASS. Bounded by the
// number of aircraft classes the mission actually uses, which is a handful.
GVAR(weaponCache) = createHashMap;

// One record per aircraft striking on THIS machine, and the id of the shared
// per-frame handler driving them. -1 means the handler does not exist, which is the
// state between strikes: idle cost is nothing, not merely small.
GVAR(active) = [];
GVAR(pfh) = -1;

// Wall clock of the previous tick, so the steering can work in real time rather
// than in frames.
GVAR(lastTick) = 0;

// The aim session in progress on THIS client, [] when there is none.
GVAR(aiming) = [];

#include "initSettings.inc.sqf"

ADDON = true;
