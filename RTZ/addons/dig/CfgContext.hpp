class zen_context_menu_actions {
    class GVAR(dig) {
        displayName = CSTRING(ActionDig);
        icon = ICON_DIG;
        statement = QUOTE([ARR_2(_position,_objects)] call FUNC(beginAiming));
        condition = QUOTE([ARR_2(_position,_objects)] call FUNC(canDig));
        priority = 41;
    };
};
