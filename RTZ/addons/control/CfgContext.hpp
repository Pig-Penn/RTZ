class zen_context_menu_actions {
    // Squad hide/freeze and LAMBS reset sit under the shared RTZ_Control submenu
    // (declared in rtz_common/CfgZenContext.hpp); reload sits at the menu root,
    // matching where it has always been offered.
    class RTZ_Control {
        class GVAR(squadHide) {
            displayName = CSTRING(ActionDisableSimulation);
            icon = ICON_HIDE;
            statement = QUOTE((_objects + [_hoveredEntity]) call FUNC(squadHideToggle));
            condition = QUOTE(GVAR(enableSquadHide) && {((_objects + [_hoveredEntity]) call EFUNC(common,collectSquads)) isNotEqualTo []});
            modifierFunction = QUOTE([ARR_2(_this select 0,_objects + [_hoveredEntity])] call FUNC(squadHideActionModifier));
            priority = 2;
        };

        class GVAR(lambsReset) {
            displayName = CSTRING(ActionReset);
            icon = "\a3\3DEN\Data\CfgWaypoints\cycle_ca.paa";
            statement = QUOTE([ARR_3(_objects,_groups,_hoveredEntity)] call FUNC(lambsReset));
            condition = QUOTE(isClass (configFile >> 'CfgPatches' >> 'lambs_wp') && {_groups findIf {units _x findIf {!isPlayer _x} != -1} != -1 || {((_objects + [_hoveredEntity]) call EFUNC(common,collectSquads)) findIf {units _x findIf {!isPlayer _x} != -1} != -1}});
            priority = 1;
        };
    };

    class GVAR(reload) {
        displayName = CSTRING(ActionReload);
        icon = "\A3\ui_f\data\igui\cfg\simpletasks\types\rearm_ca.paa";
        statement = QUOTE([ARR_2(_objects,_hoveredEntity)] call FUNC(reloadSquad));
        condition = QUOTE(GVAR(enableReloadSquad) && {((_objects + [_hoveredEntity]) call EFUNC(common,collectSquads)) isNotEqualTo []});
        priority = 1;
    };
};
