#include "script_component.hpp"

class CfgPatches {
    class ADDON {
        name = COMPONENT_NAME;
        units[] = {};
        weapons[] = {};
        requiredVersion = REQUIRED_VERSION;
        // rtz_common is required twice over: FUNC(dispatchContact) resolves the
        // firing gun's display name through EFUNC(common,classInfo), and the
        // context action below hangs off the shared RTZ_Overlays submenu root
        // declared in common/CfgZenContext.hpp — ZEN's addAction drops an action
        // whose parent node is missing.
        //
        // zen_modules is required by the fire mission action, which does not
        // reimplement ZEN's dialog: it seeds zen_modules_saved, attaches a
        // zen_modules_moduleFireMission logic and opens zen_modules_RscFireMission.
        // All three live in that addon (see FUNC(selectFireMission)).
        //
        // rtz_core is deliberately NOT listed. This component draws on the Zeus MAP
        // only, through a Draw handler on the curator display's map control; it
        // registers no renderer with core's frame loop and declares no stream, so
        // there is no contract of core's to include and no edge to declare. See
        // the note in script_component.hpp.
        requiredAddons[] = {"rtz_main", "rtz_common", "zen_common", "zen_context_menu", "zen_modules"};
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
