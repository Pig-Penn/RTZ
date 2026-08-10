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
        // zen_context_actions and zen_modules are what the arsenal gate patches:
        // the Loadout action lives in the former, the Arsenal module in the
        // latter. Listing them is also what puts this component after them in
        // the load order, which is the only reason the patches land on top of
        // ZEN's classes rather than under them.
        requiredAddons[] = {
            "rtz_main",
            "zen_common",
            "zen_attributes",
            "zen_context_menu",
            "zen_context_actions",
            "zen_modules"
        };
        author = "Maxim";
        authors[] = {"Maxim"};
        url = "";
        VERSION_CONFIG;
    };
};

#include "CfgEventHandlers.hpp"
#include "CfgContext.hpp"
#include "CfgVehicles.hpp"
#include "gui.hpp"
