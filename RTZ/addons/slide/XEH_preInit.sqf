#include "script_component.hpp"

ADDON = false;

PREP_RECOMPILE_START;
#include "XEH_PREP.hpp"
PREP_RECOMPILE_END;

// Straight-line drives currently running on this machine, one record per vehicle
// (layout in script_component.hpp). Declared outside the recompile block so a
// live recompile swaps the functions without stranding maneuvers already in
// flight — their drivers would never be released.
//
// The per-frame handler that drives them is created with the first maneuver and
// destroyed with the last (FUNC(slideTo), FUNC(slideTick)); -1 is the
// "no handler exists" sentinel, matching CBA's own handle convention.
GVAR(active) = [];
GVAR(pfh) = -1;

// When the handler last ran, for the frame delta its speed ramps integrate over.
// One clock for the whole pass rather than one per maneuver — every record on a
// given frame is being advanced across the same interval. Re-seeded whenever the
// handler is created (FUNC(slideTo)), so the gap between engagements never
// reaches the ramp.
GVAR(lastTick) = 0;

#include "initSettings.inc.sqf"
#include "initKeybinds.inc.sqf"

ADDON = true;
