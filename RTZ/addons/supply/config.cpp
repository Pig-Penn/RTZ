#include "script_component.hpp"

class CfgPatches {
    class ADDON {
        name = COMPONENT_NAME;
        units[] = {};
        weapons[] = {};
        requiredVersion = REQUIRED_VERSION;
        // rtz_hud is required for ORDERING, not for features: the
        // supply-lines overlay registers itself into that addon's stream
        // registries from XEH_postInit, and those registries are built in the
        // engine's own postInit. requiredAddons is what guarantees it runs first.
        requiredAddons[] = {"rtz_main", "rtz_common", "rtz_core", "zen_context_menu"};
        author = "Maxim";
        authors[] = {"Maxim"};
        url = "";
        VERSION_CONFIG;
    };
};

#include "CfgEventHandlers.hpp"
#include "CfgContext.hpp"
