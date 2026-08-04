class zen_context_menu_actions {
    // Single order covering all three services: whichever of repair / fuel /
    // ammo the selected supply vehicle carries is applied to everything
    // serviceable parked around it.
    class GVAR(resupply) {
        displayName = CSTRING(ActionResupply);
        icon = ICON_RESUPPLY;
        statement = QUOTE([_objects] call FUNC(orderResupply));
        condition = QUOTE([_objects] call FUNC(canResupply));
        // Relabels to Repair/Refuel/Rearm (with the matching icon) when every
        // selected supply vehicle offers only that one service.
        modifierFunction = QUOTE([ARR_2(_this select 0,_objects)] call FUNC(resupplyActionModifier));
        priority = 26;
    };

    // NO supply-lines entry in the shared RTZ_Overlays submenu, unlike rtz_hud's
    // destination and target overlays: the lines are ALWAYS drawn (subject to
    // GVAR(enableSupplyDisplay)), so there is nothing for a curator to switch on.
    // FUNC(syncDisplay) owns the stream's on/off state instead.
};
