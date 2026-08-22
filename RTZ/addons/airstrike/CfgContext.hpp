class zen_context_menu_actions {
    class GVAR(strike) {
        displayName = CSTRING(ActionAirstrike);
        icon = ICON_STRIKE;
        insertChildren = QUOTE([ARR_2(_position,_objects)] call FUNC(strikeActions));
        condition = QUOTE([ARR_2(_position,_objects)] call FUNC(canStrike));
        priority = 44;
    };
};
