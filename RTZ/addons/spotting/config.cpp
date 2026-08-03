#include "script_component.hpp"

class CfgPatches {
    class ADDON {
        name = COMPONENT_NAME;
        units[] = {};
        weapons[] = {};
        requiredVersion = REQUIRED_VERSION;
        // rtz_core owns the single Draw3D handler every RTZ display draws from,
        // which this component registers FUNC(drawSpots) and FUNC(drawRcIndicator)
        // with. That is the only RTZ dependency this component's drawing carries.
        //
        // rtz_hud is deliberately NOT listed. The two renderers used to live over
        // there, which required it — but they read six of this component's globals
        // in the process, so rtz_hud depended on rtz_spotting just as hard while
        // declaring nothing, and a mutual requiredAddons leaves Arma's load order
        // between the two undefined. The renderers moved here, to the data they
        // read; now neither addon needs the other.
        requiredAddons[] = {"rtz_main", "rtz_common", "rtz_core", "zen_context_menu"};
        author = "Maxim";
        authors[] = {"Maxim"};
        url = "";
        VERSION_CONFIG;
    };
};

#include "CfgEventHandlers.hpp"
#include "CfgContext.hpp"
