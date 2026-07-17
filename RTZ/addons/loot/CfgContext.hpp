class zen_context_menu_actions {
    // Parent submenu anchor, declared in rtz_common (CfgZenContext.hpp) - re-opened
    // here only to hang the action off it, so none of its own properties are
    // repeated. rtz_common is in requiredAddons, which guarantees it is parsed first.
    class RTZ_RealTimeZeus {
        // The selection is resolved through FUNC(canLoot), which also carries the
        // GVAR(enabled) master switch, so the condition string stays a plain
        // function call (see rtz_mine).
        class GVAR(loot) {
            displayName = CSTRING(ActionLoot);
            icon = ICON_ACTION;
            statement = QUOTE([ARR_2(_objects,_hoveredEntity)] call FUNC(orderLoot));
            condition = QUOTE([ARR_2(_objects,_hoveredEntity)] call FUNC(canLoot));
            priority = 2;
        };
    };
};
