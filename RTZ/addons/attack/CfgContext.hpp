class zen_context_menu_actions {
    class GVAR(destroy) {
        displayName = CSTRING(ActionDestroy);
        icon = ICON_ATTACK;
        statement = QUOTE(_objects call FUNC(orderDestroy));
        condition = QUOTE((_objects call FUNC(getGroups)) isNotEqualTo []);
        priority = 80;
    };
};
