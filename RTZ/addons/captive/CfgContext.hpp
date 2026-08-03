class zen_context_menu_actions {
    // Root-level toggle, alongside the other primary order actions (attack,
    // repair, loot, mine, assemble). Label and icon tint track the first
    // eligible unit's current state via FUNC(surrenderActionModifier);
    // clicking it flips every eligible unit through FUNC(surrenderToggle).
    //
    // GVAR(enabled) is read here, live, on every menu open — the component
    // installs nothing behind it (see XEH_postInit), so this is the only gate
    // the master switch needs and flipping it mid-mission works.
    //
    // ZEN runs the modifier and then the condition each time the menu is built.
    // Both are findIf-based (FUNC(canSurrender) and the modifier's own scan) so
    // that pair of passes stops at the first eligible unit instead of building
    // the whole eligible list twice.
    class GVAR(toggleSurrender) {
        displayName = CSTRING(ActionSurrender);
        icon = ICON_SURRENDER;
        statement = QUOTE([_objects + [_hoveredEntity]] call FUNC(surrenderToggle));
        condition = QUOTE(GVAR(enabled) && {[_objects + [_hoveredEntity]] call FUNC(canSurrender)});
        modifierFunction = QUOTE([ARR_2(_this select 0,_objects + [_hoveredEntity])] call FUNC(surrenderActionModifier));
        priority = 25;
    };
};
