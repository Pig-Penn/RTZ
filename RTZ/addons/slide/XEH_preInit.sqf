#include "script_component.hpp"

ADDON = false;

PREP_RECOMPILE_START;
#include "XEH_PREP.hpp"
PREP_RECOMPILE_END;

// Reverse maneuvers currently running on this machine, one record per vehicle
// (layout in script_component.hpp). Declared outside the recompile block so a
// live recompile swaps the functions without stranding maneuvers already in
// flight — their drivers would never be released.
//
// The per-frame handler that drives them is created with the first maneuver and
// destroyed with the last (FUNC(reverseTo), FUNC(reverseTick)); -1 is the
// "no handler exists" sentinel, matching CBA's own handle convention.
GVAR(active) = [];
GVAR(pfh) = -1;

#include "initSettings.inc.sqf"
#include "initKeybinds.inc.sqf"

ADDON = true;
