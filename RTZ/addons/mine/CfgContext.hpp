class zen_context_menu_actions {
    class GVAR(place) {
        displayName = CSTRING(ActionPlace);
        icon = "\a3\ui_f\data\igui\cfg\simpleTasks\types\destroy_ca.paa";
        insertChildren = QUOTE(_this call FUNC(placeActions));
        priority = 43;
    };

    class GVAR(disarm) {
        displayName = CSTRING(ActionDisarm);
        icon = "\a3\ui_f\data\igui\cfg\simpleTasks\types\repair_ca.paa";
        statement = QUOTE([ARR_2(_position,_objects)] call FUNC(orderDisarm));
        condition = QUOTE([ARR_2(_position,_objects)] call FUNC(canDisarm));
        priority = 42;
    };
};
