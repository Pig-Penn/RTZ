class zen_context_menu_actions {
    class GVAR(destroy) {
        displayName = CSTRING(ActionDestroy);
        icon = "\a3\ui_f\data\igui\cfg\simpleTasks\types\attack_ca.paa";
        statement = QUOTE(_objects call FUNC(orderDestroy));
        condition = QUOTE((_objects call FUNC(getGroups)) isNotEqualTo []);
        priority = 28;
    };
};
