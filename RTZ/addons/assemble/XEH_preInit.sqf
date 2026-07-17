#include "script_component.hpp"

ADDON = false;

PREP_RECOMPILE_START;
#include "XEH_PREP.hpp"
PREP_RECOMPILE_END;

// The vanilla curator "module" cog both context actions draw, resolved live rather
// than hardcoded (see script_component.hpp) and stamped onto the actions by the
// modifierFunction in CfgContext.hpp
GVAR(icon) = getText (configFile >> "CfgVehicleIcons" >> ICON_CONFIG_ENTRY);

// GVAR(disassembleMap) is built lazily on the first right-click of a static weapon
// and cached from there on — see FUNC(getDisassembleMap)

#include "initSettings.inc.sqf"

ADDON = true;
