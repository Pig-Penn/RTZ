#include "script_component.hpp"

class CfgPatches {
    class ADDON {
        name = COMPONENT_NAME;
        units[] = {};
        weapons[] = {};
        requiredVersion = REQUIRED_VERSION;
        // Every handler here is a self-contained keybind that reads curatorSelected
        // and reports through zen_common_fnc_showMessage / drawHint. rtz_common is
        // in for one helper: FUNC(toggleCombatMode) normalizes its selection through
        // EFUNC(common,collectUnits), the same expansion every context action uses to
        // turn a picked vehicle into its crew.
        requiredAddons[] = {"rtz_main", "rtz_common", "zen_common"};
        author = "Maxim";
        authors[] = {"Maxim"};
        url = "";
        VERSION_CONFIG;
    };
};

#include "CfgEventHandlers.hpp"
