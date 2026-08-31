#include "script_component.hpp"

class CfgPatches {
    class ADDON {
        name = COMPONENT_NAME;
        units[] = {};
        weapons[] = {};
        requiredVersion = REQUIRED_VERSION;
        // rtz_common carries EFUNC(common,curatorsOf) and EFUNC(common,sideColor);
        // rtz_core carries the frame loop this component's 3D marker registers with.
        requiredAddons[] = {"rtz_main", "rtz_common", "rtz_core", "zen_common"};
        author = "Maxim";
        authors[] = {"Maxim"};
        url = "";
        VERSION_CONFIG;
    };
};

#include "CfgEventHandlers.hpp"
