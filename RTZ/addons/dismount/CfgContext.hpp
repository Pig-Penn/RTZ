class zen_context_menu_actions {
    // Sits at the top of the shared RTZ_Control submenu (declared in
    // rtz_common/CfgZenContext.hpp), above squad hide/freeze and reset.
    // Label and icon tint track the hovered/selected vehicles' current state
    // via FUNC(dismountActionModifier); clicking it flips every resolved
    // vehicle through FUNC(toggleUnloadInCombat).
    //
    // All three entry points resolve the same object set — the selection PLUS
    // the hovered entity, so a right-click on an unselected vehicle works —
    // through the same FUNC(collectDismountVehicles), which is also what drops
    // static weapons (HMGs, mortars, GMGs: nothing to hold in a seat). Keep
    // them identical: a condition that resolves a different set than the
    // statement produces an action whose label lies about what it will do.
    class RTZ_Control {
        class GVAR(toggleDismount) {
            displayName = CSTRING(ActionForbidDismount);
            icon = ICON_LOCKED;
            statement = QUOTE([_objects + [_hoveredEntity]] call FUNC(toggleUnloadInCombat));
            condition = QUOTE(GVAR(enableDismountControl) && {([_objects + [_hoveredEntity]] call FUNC(collectDismountVehicles)) isNotEqualTo []});
            modifierFunction = QUOTE([ARR_2(_this select 0,_objects + [_hoveredEntity])] call FUNC(dismountActionModifier));
            priority = 4;
        };
    };
};
