class zen_context_menu_actions {
    class RTZ_Control {
        class GVAR(reload) {
            displayName = CSTRING(ActionReload);
            icon = ICON_RELOAD;
            statement = QUOTE([ARR_2(_objects,_hoveredEntity)] call FUNC(reloadSquad));
            condition = QUOTE(GVAR(enableReloadSquad) && {([_objects + [_hoveredEntity]] call EFUNC(common,collectSquads)) isNotEqualTo []});
            priority = 3;
        };

        class GVAR(squadHide) {
            displayName = CSTRING(ActionDisableSimulation);
            icon = ICON_HIDE;
            statement = QUOTE([_objects + [_hoveredEntity]] call FUNC(squadHideToggle));
            condition = QUOTE(GVAR(enableSquadHide) && {([_objects + [_hoveredEntity]] call EFUNC(common,collectSquads)) isNotEqualTo []});
            modifierFunction = QUOTE([ARR_2(_this select 0,_objects + [_hoveredEntity])] call FUNC(squadHideActionModifier));
            priority = 2;
        };

        class GVAR(lambsReset) {
            displayName = CSTRING(ActionReset);
            icon = ICON_RESET;
            statement = QUOTE([ARR_3(_objects,_groups,_hoveredEntity)] call FUNC(lambsReset));
            condition = QUOTE(isClass (configFile >> 'CfgPatches' >> 'lambs_wp') && {_groups findIf {units _x findIf {!isPlayer _x} != -1} != -1 || {([_objects + [_hoveredEntity]] call EFUNC(common,collectSquads)) findIf {units _x findIf {!isPlayer _x} != -1} != -1}});
            priority = 1;
        };
    };
};
