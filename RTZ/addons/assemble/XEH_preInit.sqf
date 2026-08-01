#include "script_component.hpp"

ADDON = false;

PREP_RECOMPILE_START;
#include "XEH_PREP.hpp"
PREP_RECOMPILE_END;

// The vanilla curator "module" cog both context actions draw, resolved live rather
// than hardcoded (see script_component.hpp) and stamped onto the actions by the
// modifierFunction in CfgContext.hpp
GVAR(icon) = getText (configFile >> "CfgVehicleIcons" >> ICON_CONFIG_ENTRY);

// The vanilla assemble config, read once into GVAR(bagInfo) / GVAR(disassembleMap) so
// the context-menu path never touches configFile — see FUNC(buildBagMaps). Only the
// ordering curator's client reads them (the action conditions and the two
// collectors), so a dedicated server or headless client skips the scan; the errand
// handlers that run there deliberately don't consult the maps. Both are still
// defined there, empty, so a lookup from an unexpected caller comes back empty
// rather than throwing on an undefined variable.
GVAR(bagInfo) = createHashMap;
GVAR(disassembleMap) = createHashMap;

if (hasInterface) then {
    call FUNC(buildBagMaps);
};

#include "initSettings.inc.sqf"

ADDON = true;
