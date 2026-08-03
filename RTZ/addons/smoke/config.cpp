#include "script_component.hpp"

class CfgPatches {
    class ADDON {
        name = COMPONENT_NAME;
        units[] = {};
        weapons[] = {};
        requiredVersion = REQUIRED_VERSION;
        // rtz_common for the selection normalizer (EFUNC(common,collectVehicles))
        // and the curator toast (EFUNC(common,showCountMessage)); zen_context_menu
        // for the action in CfgContext.hpp.
        requiredAddons[] = {"rtz_main", "rtz_common", "zen_context_menu"};
        author = "Maxim";
        authors[] = {"Maxim"};
        url = "";
        VERSION_CONFIG;
    };
};

#include "CfgEventHandlers.hpp"
#include "CfgContext.hpp"
