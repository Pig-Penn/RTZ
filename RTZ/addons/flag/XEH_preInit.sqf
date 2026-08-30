#include "script_component.hpp"

ADDON = false;

PREP_RECOMPILE_START;
#include "XEH_PREP.hpp"
PREP_RECOMPILE_END;

// GVAR(factionFlags): faction (lowercased) -> normalised flag texture, resolved
// from CfgFactionClasses ONCE here. The context-menu condition runs on every
// menu open, so it must be a hash lookup and never a config read.
#include "defaultFlags.inc.sqf"

ADDON = true;
