#include "script_component.hpp"

class CfgPatches {
    class ADDON {
        name = COMPONENT_NAME;
        units[] = {};
        weapons[] = {};
        requiredVersion = REQUIRED_VERSION;
        // rtz_core for the frame loop the route renderer registers with,
        // rtz_common for the selection normalizers and the curator message helper.
        requiredAddons[] = {"rtz_main", "rtz_common", "rtz_core", "zen_common"};
        author = "Maxim";
        authors[] = {"Maxim"};
        url = "";
        VERSION_CONFIG;
    };
};

#include "CfgEventHandlers.hpp"
