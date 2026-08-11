#include "script_component.hpp"

class CfgPatches {
    class ADDON {
        name = COMPONENT_NAME;
        units[] = {};
        weapons[] = {};
        requiredVersion = REQUIRED_VERSION;
        // lambs_wp is a HARD edge, not a soft one: FUNC(resetApply) CALLS
        // lambs_wp_fnc_taskReset (it does not merely read a LAMBS variable by
        // name with a default, which is what the soft reads elsewhere in the mod
        // do). It is the only live LAMBS call in RTZ — every other lambs_*_fnc_
        // mention is a comment citing the technique, and rtz_hud deliberately
        // INLINED lambs_main_fnc_debugDangerType to avoid acquiring this very
        // edge. Undeclared, the mod loads happily without LAMBS and the call
        // throws on a nil, which aborts the whole scope (Gotchas §2): the
        // doWatch/lookAt clear below it never runs and the forEach over the
        // remaining groups dies with it, so a squad reset half-executes in
        // silence. Declaring it also pins the load order, which requiredAddons is
        // the only mechanism for. lambs_wp pulls lambs_danger -> lambs_main.
        requiredAddons[] = {"rtz_main", "rtz_common", "rtz_core", "zen_common", "zen_context_menu", "lambs_wp"};
        author = "Maxim";
        authors[] = {"Maxim"};
        url = "";
        VERSION_CONFIG;
    };
};

#include "CfgEventHandlers.hpp"
#include "CfgContext.hpp"
