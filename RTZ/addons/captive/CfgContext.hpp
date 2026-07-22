class zen_context_menu_actions {
    // Root-level toggle, alongside the other primary order actions (attack,
    // repair, loot, mine, assemble). Label and icon tint track the first
    // selected/hovered unit's current state via FUNC(surrenderActionModifier);
    // clicking it flips every eligible unit through FUNC(surrenderToggle).
    class GVAR(toggleSurrender) {
        displayName = CSTRING(ActionSurrender);
        icon = ICON_SURRENDER;
        statement = QUOTE([_objects + [_hoveredEntity]] call FUNC(surrenderToggle));
        condition = QUOTE(GVAR(enableSurrender) && {([_objects + [_hoveredEntity]] call FUNC(collectSurrenderUnits)) isNotEqualTo []});
        modifierFunction = QUOTE([ARR_2(_this select 0,_objects + [_hoveredEntity])] call FUNC(surrenderActionModifier));
        priority = 25;
    };
};
