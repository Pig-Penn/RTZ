#include "script_component.hpp"

class CfgPatches {
    class ADDON {
        name = COMPONENT_NAME;
        units[] = {};
        weapons[] = {};
        requiredVersion = REQUIRED_VERSION;
        // Two separate dependencies, both one-way:
        //   rtz_core owns the single Draw3D handler every RTZ display draws from,
        //     which this component registers its renderers with.
        //   rtz_hud owns the RENDERERS themselves (EFUNC(hud,drawSpots) /
        //     EFUNC(hud,drawRcIndicator)) — this component decides what is spotted,
        //     rtz_hud decides how it looks, and rtz_hud never reads rtz_spotting.
        // The comment here used to credit rtz_hud with owning the handler as well,
        // which stopped being true when the frame loop moved into rtz_core.
        requiredAddons[] = {"rtz_main", "rtz_common", "rtz_core", "rtz_hud", "zen_context_menu"};
        author = "Maxim";
        authors[] = {"Maxim"};
        url = "";
        VERSION_CONFIG;
    };
};

#include "CfgEventHandlers.hpp"
#include "CfgContext.hpp"
