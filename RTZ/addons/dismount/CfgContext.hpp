class zen_context_menu_actions {
    // Sits at the top of the shared RTZ_Control submenu (declared in
    // rtz_common/CfgZenContext.hpp), above squad hide/freeze and reset.
    // Label and icon tint track the hovered/selected vehicle's current state
    // via FUNC(dismountActionModifier); clicking it flips every selected
    // vehicle through FUNC(toggleUnloadInCombat). Static weapons (HMGs,
    // mortars, GMGs) have no dismount concept, so the condition excludes a
    // selection that resolves to nothing but StaticWeapons.
    class RTZ_Control {
        class GVAR(toggleDismount) {
            displayName = CSTRING(ActionForbidDismount);
            icon = ICON_LOCKED;
            statement = QUOTE([_objects] call FUNC(toggleUnloadInCombat));
            condition = QUOTE(GVAR(enableDismountControl) && {(([_objects] call EFUNC(common,collectVehicles)) findIf { !(_x isKindOf 'StaticWeapon') }) != -1});
            modifierFunction = QUOTE([ARR_2(_this select 0,_objects + [_hoveredEntity])] call FUNC(dismountActionModifier));
            priority = 4;
        };
    };
};
