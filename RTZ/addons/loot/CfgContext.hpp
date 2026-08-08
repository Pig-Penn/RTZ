class zen_context_menu_actions {
    // The selection is resolved through FUNC(canLoot), which also carries the
    // GVAR(enabled) master switch, so the condition string stays a plain
    // function call (see rtz_mine).
    class GVAR(loot) {
        displayName = CSTRING(ActionLoot);
        icon = ICON_ACTION;
        statement = QUOTE([ARR_2(_objects,_hoveredEntity)] call FUNC(orderLoot));
        condition = QUOTE([ARR_2(_objects,_hoveredEntity)] call FUNC(canLoot));
        priority = 34;
    };
};
