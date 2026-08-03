#include "script_component.hpp"

class CfgPatches {
    class ADDON {
        name = COMPONENT_NAME;
        units[] = {};
        weapons[] = {};
        requiredVersion = REQUIRED_VERSION;
        // rtz_common for the shared toast helper the overlay toggle reports
        // through; zen_context_menu because the selection poll registers the
        // shared RTZ_Overlays anchor's siblings. NOT rtz_hud — that is the whole
        // point: the displays depend on the engine, never the other way round.
        requiredAddons[] = {"rtz_main", "rtz_common", "zen_context_menu"};
        author = "Maxim";
        authors[] = {"Maxim"};
        url = "";
        VERSION_CONFIG;
    };
};

#include "CfgEventHandlers.hpp"
