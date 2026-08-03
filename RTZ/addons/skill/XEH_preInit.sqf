#include "script_component.hpp"

ADDON = false;

PREP_RECOMPILE_START;
#include "XEH_PREP.hpp"
PREP_RECOMPILE_END;

// GVAR(defaultSkills): classname (lowercased) -> overall skill, built from the
// per-faction tables under defaultSkills\. Must exist before the CAManBase
// handler in postInit fires for the first spawned unit.
#include "defaultSkills.inc.sqf"

ADDON = true;
