#include "script_component.hpp"

class CfgPatches {
    class ADDON {
        name = COMPONENT_NAME;
        units[] = {};
        weapons[] = {};
        requiredVersion = REQUIRED_VERSION;
        // No RTZ dependency beyond the framework: the skill table is applied
        // from a CAManBase class event handler and reads nothing but the unit's
        // own type. Deliberately NOT rtz_common — this used to live there, and
        // a per-faction data table is a feature, not shared infrastructure.
        requiredAddons[] = {"rtz_main"};
        author = "Maxim";
        authors[] = {"Maxim"};
        url = "";
        VERSION_CONFIG;
    };
};

#include "CfgEventHandlers.hpp"
