#include "script_component.hpp"

class CfgPatches {
    class ADDON {
        name = COMPONENT_NAME;
        units[] = {};
        weapons[] = {};
        requiredVersion = REQUIRED_VERSION;
        requiredAddons[] = {"cba_main", "zen_main"};
        author = "Maxim";
        authors[] = {"Maxim"};
        url = "";
        VERSION_CONFIG;
    };
};

#include "CfgSettings.hpp"
