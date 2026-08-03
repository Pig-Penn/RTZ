#include "script_component.hpp"

class CfgPatches {
    class ADDON {
        name = COMPONENT_NAME;
        units[] = {};
        weapons[] = {};
        requiredVersion = REQUIRED_VERSION;
        // zen_common only: every handler here is a self-contained keybind that
        // reads curatorSelected and reports through zen_common_fnc_showMessage /
        // drawHint. No rtz_common — these orders call none of its helpers, which
        // is why they could leave it.
        requiredAddons[] = {"rtz_main", "zen_common"};
        author = "Maxim";
        authors[] = {"Maxim"};
        url = "";
        VERSION_CONFIG;
    };
};

#include "CfgEventHandlers.hpp"
