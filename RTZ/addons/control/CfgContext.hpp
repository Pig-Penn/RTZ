class zen_context_menu_actions {
    // A one-shot ORDER, not a state toggle, so it sits at the menu root with the
    // other orders (attack, assemble, loot, deploy countermeasures) rather than
    // in the RTZ_Control submenu of toggles it used to share with dismount and
    // disable-simulation.
    //
    // Hidden unless the click would change something: FUNC(collectReloadSquads)
    // drops the squads whose every weapon is already holding the best magazine
    // its owner carries. Condition and statement resolve the same set through
    // the same function — see FUNC(collectDismountVehicles) for why the two must
    // not be allowed to disagree.
    class GVAR(reload) {
        displayName = CSTRING(ActionReload);
        icon = ICON_RELOAD;
        statement = QUOTE([ARR_2(_objects,_hoveredEntity)] call FUNC(reloadSquad));
        condition = QUOTE(GVAR(enableReloadSquad) && {([_objects + [_hoveredEntity]] call FUNC(collectReloadSquads)) isNotEqualTo []});
        priority = 33;
    };

    // Only appears while the selection actually holds a non-local group, so
    // it stays invisible in normal play and surfaces exactly when a squad's
    // simulation needs pulling back (typically after a curator rejoined).
    // Deliberately sits at the menu ROOT rather than under RTZ_Control: the
    // condition already keeps it hidden almost always, and when it does show
    // up the curator is troubleshooting and should not have to hunt for it.
    class GVAR(takeOwnership) {
        displayName = CSTRING(ActionTakeOwnership);
        icon = ICON_OWNERSHIP;
        statement = QUOTE([ARR_2(_objects,_hoveredEntity)] call FUNC(takeOwnership));
        condition = QUOTE(GVAR(enableTakeOwnership) && {[ARR_2(_objects,_hoveredEntity)] call FUNC(canTakeOwnership)});
        priority = 0;
    };

    class RTZ_Control {
        // Label and icon tint track the hovered/selected vehicles' current
        // state via FUNC(dismountActionModifier); clicking it flips every
        // resolved vehicle through FUNC(dismountToggle).
        //
        // All three entry points resolve the same object set — the selection
        // PLUS the hovered entity, so a right-click on an unselected vehicle
        // works — through the same FUNC(collectDismountVehicles), which is also
        // what drops static weapons (HMGs, mortars, GMGs: nothing to hold in a
        // seat). Keep them identical: a condition that resolves a different set
        // than the statement produces an action whose label lies about what it
        // will do.
        class GVAR(dismount) {
            displayName = CSTRING(ActionForbidDismount);
            icon = ICON_LOCKED;
            statement = QUOTE([_objects + [_hoveredEntity]] call FUNC(dismountToggle));
            condition = QUOTE(GVAR(enableDismount) && {([_objects + [_hoveredEntity]] call FUNC(collectDismountVehicles)) isNotEqualTo []});
            modifierFunction = QUOTE([ARR_2(_this select 0,_objects + [_hoveredEntity])] call FUNC(dismountActionModifier));
            priority = 4;
        };

        // Third state, checked first by the modifier/toggle: a group still
        // under the editor-placed Dynamic Simulation system shows blue and
        // this click turns that off instead of hiding/freezing. See
        // FUNC(squadHideActionModifier).
        class GVAR(squadHide) {
            displayName = CSTRING(ActionDisableSimulation);
            icon = ICON_HIDE;
            statement = QUOTE([_objects + [_hoveredEntity]] call FUNC(squadHideToggle));
            condition = QUOTE(GVAR(enableSquadHide) && {([_objects + [_hoveredEntity]] call EFUNC(common,collectSquads)) isNotEqualTo []});
            modifierFunction = QUOTE([ARR_2(_this select 0,_objects + [_hoveredEntity])] call FUNC(squadHideActionModifier));
            priority = 2;
        };

        class GVAR(reset) {
            displayName = CSTRING(ActionReset);
            icon = ICON_RESET;
            statement = QUOTE([ARR_3(_objects,_groups,_hoveredEntity)] call FUNC(reset));
            condition = QUOTE(GVAR(enableReset) && {[ARR_3(_objects,_groups,_hoveredEntity)] call FUNC(canReset)});
            priority = 0;
        };
    };
};
