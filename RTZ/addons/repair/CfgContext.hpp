class zen_context_menu_actions {
    class GVAR(repair) {
        displayName = CSTRING(ActionRepair);
        icon = "\a3\ui_f\data\igui\cfg\simpleTasks\types\repair_ca.paa";
        statement = QUOTE([ARR_2(_position,_objects)] call FUNC(orderRepair));
        condition = QUOTE([ARR_2(_position,_objects)] call FUNC(canRepair));
        priority = 27;
    };
};
