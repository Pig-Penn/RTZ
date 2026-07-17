class zen_context_menu_actions {
    class GVAR(toggleArea) {
        displayName = CSTRING(ActionAdd);
        icon = ICON_ADD;
        statement = QUOTE((_objects + [_hoveredEntity]) call FUNC(toggleArea));
        condition = QUOTE(GVAR(enable) && {((_objects + [_hoveredEntity]) call FUNC(getOfficers)) isNotEqualTo []});
        modifierFunction = QUOTE([ARR_2(_this select 0,_objects + [_hoveredEntity])] call FUNC(modifyAction));
        priority = 27;
    };
    class GVAR(toggleAura) {
        displayName = CSTRING(ActionAuraAdd);
        icon = ICON_ADD;
        statement = QUOTE((_objects + [_hoveredEntity]) call FUNC(toggleAura));
        condition = QUOTE(GVAR(auraEnable) && {((_objects + [_hoveredEntity]) call FUNC(getOfficers)) isNotEqualTo []});
        modifierFunction = QUOTE([ARR_2(_this select 0,_objects + [_hoveredEntity])] call FUNC(modifyAuraAction));
        priority = 26;
    };
};
