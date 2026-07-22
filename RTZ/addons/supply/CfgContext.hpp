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
};
