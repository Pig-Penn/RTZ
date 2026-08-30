class zen_context_menu_actions {
    // Hangs off rtz_common's RTZ_Vehicle folder — everything a curator does TO a
    // vehicle in one place. Config-declared children survive that folder being
    // filled at runtime: EFUNC(common,regroupVehicleActions) APPENDS ZEN's moved
    // entries onto whatever children config already put there.
    //
    // This is the first CONFIG-declared child that folder has ever had, which
    // changes one thing rtz_common documents: RTZ_Vehicle used to start empty,
    // so with EGVAR(common,enableCleanContextMenu) off — it is local, and
    // defaults on — the folder never rendered and ZEN's own Vehicle Logistics
    // stood alone. It can now render holding only this entry. Left that way on
    // purpose: ZEN skips a node with no ACTIVE children, so the folder still
    // only appears when the condition below passes, and gating a flag feature
    // on another component's menu-cleaning setting would be a surprising
    // coupling to diagnose.
    class RTZ_Vehicle {
        // Hidden unless the click would change something: FUNC(collectFlagVehicles)
        // drops vehicles of unsupported factions and vehicles already flying
        // their faction's flag, so the action disappears once its work is done.
        // Condition and statement resolve the same set through that same
        // function — see rtz_control's FUNC(collectDismountVehicles) for why the
        // two must never be allowed to disagree.
        class GVAR(attachFlag) {
            displayName = CSTRING(ActionAttachFlag);
            icon = ICON_FLAG;
            statement = QUOTE([_objects + [_hoveredEntity]] call FUNC(attachFlag));
            condition = QUOTE(([_objects + [_hoveredEntity]] call FUNC(collectFlagVehicles)) isNotEqualTo []);
            // Bottom of the folder: a cosmetic action belongs under the ones that
            // change what a vehicle can DO. Explicitly NOT 0, which is where
            // ZEN's own moved-in entries all sit — CBA_fnc_sortNestedArray is not
            // a stable sort, so a tie would let the menu order shuffle between
            // clients. Inventory sits at 1.
            priority = -1;
        };
    };
};
