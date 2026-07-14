class zen_context_menu_actions {
    class GVAR(toggleArea) {
        displayName = CSTRING(ActionAdd);
        icon = ICON_ADD;
        statement = QUOTE((_objects + [_hoveredEntity]) call FUNC(toggleArea));
        condition = QUOTE(GVAR(enable) && {((_objects + [_hoveredEntity]) call FUNC(getOfficers)) isNotEqualTo []});
        modifierFunction = QUOTE([ARR_2(_this select 0,_objects + [_hoveredEntity])] call FUNC(modifyAction));
        priority = 27;
    };
};
