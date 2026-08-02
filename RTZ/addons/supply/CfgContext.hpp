class zen_context_menu_actions {
    // Single order covering all three services: whichever of repair / fuel /
    // ammo the selected supply vehicle carries is applied to everything
    // serviceable parked around it.
    class GVAR(resupply) {
        displayName = CSTRING(ActionResupply);
        icon = ICON_RESUPPLY;
        statement = QUOTE([_objects] call FUNC(orderResupply));
        condition = QUOTE([_objects] call FUNC(canResupply));
        priority = 26;
    };

    // Supply-lines overlay toggle. Hangs off the shared RTZ_Overlays submenu
    // anchor declared in rtz_common, alongside the destination and target
    // overlays — it is one more STREAM on the same engine, so it belongs in the
    // same menu even though the stream itself lives in this addon.
    //
    // Master switch, not a per-selection action: while ON the overlay follows the
    // curator's live selection rather than the current context-menu one, so the
    // condition is a plain settings check. Both settings are read LIVE, so
    // flipping either mid-mission just works.
    class RTZ_Overlays {
        class GVAR(toggleSupplyLines) {
            displayName = CSTRING(ActionDrawSupplyLines);
            icon = ICON_RESUPPLY;
            statement = QUOTE(call FUNC(toggleSupplyOverlay));
            condition = QUOTE(GVAR(enabled) && GVAR(enableSupplyDisplay));
            modifierFunction = QUOTE([_this select 0] call FUNC(supplyOverlayModifier));
            priority = 2;
        };
    };
};
