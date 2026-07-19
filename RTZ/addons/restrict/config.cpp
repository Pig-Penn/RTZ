#include "script_component.hpp"

class CfgPatches {
    class ADDON {
        name = COMPONENT_NAME;
        units[] = {};
        weapons[] = {};
        requiredVersion = REQUIRED_VERSION;
        // zen_modules: must load after its PREP so zen_modules_fnc_moduleHeal
        // exists to wrap at postInit
        requiredAddons[] = {"rtz_main", "rtz_officer", "zen_attributes", "zen_modules"};
        author = "Maxim";
        authors[] = {"Maxim"};
        url = "";
        VERSION_CONFIG;
    };
};

#include "CfgEventHandlers.hpp"
