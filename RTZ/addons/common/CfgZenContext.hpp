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
        priority = 31;
    };

    // Submenu for squad/behaviour control actions (behaviour info, disable
    // simulation, reset).
    class RTZ_Control {
        displayName = CSTRING(SubmenuControl);
        icon = ICON_SUBMENU_CONTROL;
        priority = 32;
    };

    // Everything a curator does TO a vehicle, in one folder. Unlike the two
    // above, this one starts EMPTY and is filled at runtime: it REPLACES ZEN's
    // Vehicle Logistics, and FUNC(regroupVehicleActions) moves ZEN's surviving
    // entries across as intact nodes before deleting ZEN's folder.
    //
    // Moving them beats re-declaring them here. Every entry ZEN puts in that
    // folder is implemented by a Public: No ZEN function — canUnloadViV,
    // unloadViV, getVehicleWeaponActions and the inventory serialisers — so a
    // re-declaration would have to name all of them literally from config and
    // would silently break the day ZEN renames one (a nil call aborts the whole
    // scope; Gotchas §2). A move names no ZEN function at all, and ZEN keeps
    // ownership of what its own entries do.
    //
    // Priority 37 is ZEN's own for that folder, so it lands in the same place in
    // the menu it always sat. An empty folder never renders — ZEN skips a node
    // with no statement and no active children — so if the regrouping bails,
    // this declaration is invisible rather than a dead entry.
    class RTZ_Vehicle {
        displayName = CSTRING(SubmenuVehicle);
        icon = ICON_SUBMENU_VEHICLE;
        priority = 37;
    };
};
