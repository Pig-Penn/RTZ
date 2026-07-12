class zen_context_menu_actions {
    class GVAR(toggle) {
        displayName = CSTRING(ActionShow);
        icon = "\a3\ui_f\data\igui\cfg\simpleTasks\types\heal_ca.paa";
        statement = QUOTE(_objects call FUNC(toggleUnits));
        condition = QUOTE(_objects findIf {_x isKindOf 'CAManBase' || {crew _x isNotEqualTo []}} != -1);
        modifierFunction = QUOTE([ARR_2(_this select 0,_objects)] call FUNC(modifyAction));
        priority = 40;
    };
};
