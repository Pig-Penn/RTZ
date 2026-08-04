#include "script_component.hpp"

class CfgPatches {
    class ADDON {
        name = COMPONENT_NAME;
        units[] = {};
        weapons[] = {};
        requiredVersion = REQUIRED_VERSION;
        // rtz_orders is required for one read: FUNC(gatherVehicleInfo) reports
        // the commanded fly-in height that component's keybind writes onto the
        // vehicle. One-way — rtz_orders knows nothing about this component.
        requiredAddons[] = {"rtz_main", "rtz_common", "rtz_core", "rtz_orders", "zen_common", "zen_context_menu", "zen_dialog"};
        author = "Maxim";
        authors[] = {"Maxim"};
        url = "";
        VERSION_CONFIG;
    };
};

#include "CfgEventHandlers.hpp"
#include "CfgContext.hpp"
