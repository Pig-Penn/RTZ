#include "script_component.hpp"

class CfgPatches {
    class ADDON {
        name = COMPONENT_NAME;
        units[] = {};
        weapons[] = {};
        requiredVersion = REQUIRED_VERSION;
        // No rtz_common: this component calls nothing in it. It used to be listed
        // only because initSettings.inc.sqf borrowed ELSTRING(common,DisplayName)
        // for its settings category — which also put every Restrict setting under
        // "Real-Time Zeus > Common" in CBA — to paper over a missing
        // STR_RTZ_Restrict_DisplayName. The key exists now.
        requiredAddons[] = {"rtz_main", "zen_common", "zen_attributes"};
        author = "Maxim";
        authors[] = {"Maxim"};
        url = "";
        VERSION_CONFIG;
    };
};

#include "CfgEventHandlers.hpp"
#include "gui.hpp"
