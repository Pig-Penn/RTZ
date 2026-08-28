#include "script_component.hpp"

ADDON = false;

PREP_RECOMPILE_START;
#include "XEH_PREP.hpp"
PREP_RECOMPILE_END;

// Initialised HERE rather than behind CBA_settingsInitialized: FUNC(canDig) reads it
// from a ZEN context CONDITION, which is evaluated on every context-menu open from
// the first frame the curator display exists. A nil read there is "Undefined
// variable" spam in the RPT on every right-click.
GVAR(enabled) = false;

// The drawing session in progress on THIS client, [] when there is none.
GVAR(aiming) = [];

// Diggable verdict per surface CLASS. Bounded by the terrain rather than by how long
// the mission runs — a map has a few dozen surfaces — which is what makes it safe to
// keep for the whole session. See FUNC(surfaceDiggable).
GVAR(surfaces) = createHashMap;

// SERVER: one record per trench dug this mission, capped at GVAR(maxTrenches), and
// the id the next one takes. Empty on clients, which never read it.
GVAR(trenches) = [];
GVAR(nextId) = 0;

#include "initSettings.inc.sqf"

ADDON = true;
