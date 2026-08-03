class zen_context_menu_actions {
    // The selection is resolved through FUNC(collectCasualties), which reads
    // the client-cached server state (GVAR(casualtyStates)), so the condition
    // string stays a plain function call (see rtz_mine).
    class GVAR(loadCasualty) {
        displayName = CSTRING(ActionLoadCasualty);
        icon = ICON_LOAD;
        iconColor[] = COLOR_LOAD;
        statement = QUOTE([_objects + [_hoveredEntity]] call FUNC(loadCasualty));
        condition = QUOTE(GVAR(enable) && {([_objects + [_hoveredEntity]] call FUNC(collectCasualties)) isNotEqualTo []});
        priority = 20;
    };
};
