#include "script_component.hpp"

class CfgPatches {
    class ADDON {
        name = COMPONENT_NAME;
        units[] = {};
        weapons[] = {};
        requiredVersion = REQUIRED_VERSION;
        // rtz_common for the shared toast helper the overlay toggle reports
        // through; zen_common for zen_common_fnc_showMessage, which the selection
        // poll calls directly. NOT zen_context_menu — this component has no
        // CfgContext.hpp and calls nothing in it. FUNC(toggleOverlay) and
        // FUNC(overlayActionModifier) are consumed BY other components' context
        // actions, which makes zen_context_menu their dependency, not ours. And
        // NOT rtz_hud — that is the whole point: the displays depend on the
        // engine, never the other way round.
        requiredAddons[] = {"rtz_main", "rtz_common", "zen_common"};
        author = "Maxim";
        authors[] = {"Maxim"};
        url = "";
        VERSION_CONFIG;
    };
};

#include "CfgEventHandlers.hpp"
