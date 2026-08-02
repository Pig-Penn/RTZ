#include "script_component.hpp"

class CfgPatches {
    class ADDON {
        name = COMPONENT_NAME;
        units[] = {};
        weapons[] = {};
        requiredVersion = REQUIRED_VERSION;
        // rtz_hud owns the single Draw3D handler this component's icons draw
        // from (EFUNC(hud,drawSpots) / EFUNC(hud,drawRcIndicator)); the
        // dependency runs one way only — rtz_hud never reads rtz_spotting.
        requiredAddons[] = {"rtz_main", "rtz_common", "rtz_hud", "zen_context_menu"};
        author = "Maxim";
        authors[] = {"Maxim"};
        url = "";
        VERSION_CONFIG;
    };
};

#include "CfgEventHandlers.hpp"
#include "CfgContext.hpp"
