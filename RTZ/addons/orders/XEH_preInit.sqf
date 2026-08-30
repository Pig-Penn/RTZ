#include "script_component.hpp"

ADDON = false;

PREP_RECOMPILE_START;
#include "XEH_PREP.hpp"
PREP_RECOMPILE_END;

// netId -> the AnimDone handler index installed on that man by QGVAR(gearAnimStart).
//
// MACHINE-LOCAL, AND NOT A UNIT VARIABLE. An event-handler index is meaningful only
// on the machine that added the handler, which is the same rule
// EFUNC(control,dismountApply) states for its own marker: what it guards is local,
// so the record is local.
//
// This lived on the unit as QGVAR(gearAnimEH) and that was a real bug.
// EFUNC(control,rcRebuild) replaces a released remote-control unit by deleting it
// and creating a new one, and carries its state across with a generic
// `allVariables` sweep that re-applies EVERY variable to the replacement WITH THE
// PUBLIC FLAG. Hand-added event handlers do not survive createUnit (CBA's XEH do —
// docs/Knowledge Base/Gotchas.md §3), so the rebuilt man arrived carrying an index
// naming a handler that did not exist, on every machine. The "already installed"
// guard in XEH_postInit then saw a non-nil value and exited forever: that unit's
// gear animation never worked again for the rest of the mission, silently.
//
// Removing the stale index on the replacement would have been the wrong fix — after
// a rebuild that number may name a completely different mod's handler.
//
// Bounded by the number of gear displays open across all curators at once, and
// pruned of units that were deleted mid-session on each start (see XEH_postInit).
GVAR(gearAnimEHs) = createHashMap;

#include "initSettings.inc.sqf"
#include "initKeybinds.inc.sqf"

ADDON = true;
