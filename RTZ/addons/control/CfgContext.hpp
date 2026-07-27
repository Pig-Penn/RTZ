class zen_context_menu_actions {
    // Only appears while the selection actually holds a non-local group, so
    // it stays invisible in normal play and surfaces exactly when a squad's
    // simulation needs pulling back (typically after a curator rejoined).
    // Sits at the menu root alongside the other RTS-style order actions.
    class GVAR(initControl) {
        displayName = CSTRING(ActionInit);
        icon = ICON_INIT;
        statement = QUOTE([ARR_2(_objects,_hoveredEntity)] call FUNC(initControl));
        condition = QUOTE([ARR_2(_objects,_hoveredEntity)] call FUNC(canInitControl));
        priority = 4;
    };

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

        // also takes corpses, wrecks and plain objects.
        class GVAR(deleteObjects) {
            displayName = CSTRING(ActionDelete);
            icon = ICON_DELETE;
            statement = QUOTE([ARR_3(_objects,_groups,_hoveredEntity)] call FUNC(deleteObjects));
            condition = QUOTE(GVAR(enableDelete) && {([ARR_2(_objects + [_hoveredEntity],_groups)] call FUNC(collectDeletables)) isNotEqualTo []});
            priority = 1;
        };

        class GVAR(reset) {
            displayName = CSTRING(ActionReset);
            icon = ICON_RESET;
            statement = QUOTE([ARR_3(_objects,_groups,_hoveredEntity)] call FUNC(reset));
            condition = QUOTE(_groups findIf {units _x findIf {!isPlayer _x} != -1} != -1 || {([_objects + [_hoveredEntity]] call EFUNC(common,collectSquads)) findIf {units _x findIf {!isPlayer _x} != -1} != -1});
            priority = 0;
        };
    };
};
