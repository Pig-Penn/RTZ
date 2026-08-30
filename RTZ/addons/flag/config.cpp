#include "script_component.hpp"

class CfgPatches {
    class ADDON {
        name = COMPONENT_NAME;
        units[] = {};
        weapons[] = {};
        requiredVersion = REQUIRED_VERSION;
        // rtz_common for two separate reasons: FUNC(collectFlagVehicles) calls
        // EFUNC(common,collectVehicles), and the RTZ_Vehicle submenu this
        // component hangs its action under is declared in that addon's
        // CfgZenContext.hpp — zen_context_menu_fnc_compileActions drops a child
        // whose parent node is missing.
        requiredAddons[] = {"rtz_main", "rtz_common", "zen_context_menu"};
        author = "Maxim";
        authors[] = {"Maxim"};
        url = "";
        VERSION_CONFIG;
    };
};

#include "CfgEventHandlers.hpp"
#include "CfgContext.hpp"
