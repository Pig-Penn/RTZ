// Shared parent submenu anchors for RTZ context actions that are grouped
// (Overlays, Controls). These live in rtz_common (loaded before every
// feature addon) because ZEN compiles zen_context_menu_actions from
// configFile at preInit, and all scripted zen_context_menu_fnc_addAction
// calls across the RTZ addons target these parent paths — addAction logs an
// error and drops the action if the parent node is missing. Most RTZ actions
// (reload, attack, assemble, deploy countermeasures, ...) sit at the menu
// root instead of under a submenu, and are declared in their own addon's
// CfgContext.hpp; this component now declares no actions of its own.
class zen_context_menu_actions {
    // Submenu for the toggleable draw overlays (vehicle tags, unit tags,
    // destinations, targets).
    class RTZ_Overlays {
        displayName = CSTRING(SubmenuOverlays);
        icon = ICON_SUBMENU_OVERLAYS;
        priority = 6;
    };

    // Submenu for squad/behaviour control actions (behaviour info, disable
    // simulation, reset).
    class RTZ_Control {
        displayName = CSTRING(SubmenuControl);
        icon = ICON_SUBMENU_CONTROL;
        priority = 7;
    };
};
