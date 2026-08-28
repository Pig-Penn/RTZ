class zen_context_menu_actions {
    // Sits under the shared RTZ_Overlays submenu (declared in
    // rtz_common/CfgZenContext.hpp) alongside the spotting chevron toggle, since
    // this is another toggleable draw overlay. PER-CLIENT: the contact store keeps
    // filling while the overlay is hidden, and FUNC(toggleDisplay) only detaches
    // the map Draw handler — so switching it back on shows the live picture rather
    // than starting from the next shot.
    //
    // The condition is a plain setting check because the overlay is not tied to a
    // selection: a counter-battery contact is about ground, not about whatever the
    // curator happens to have clicked.
    class RTZ_Overlays {
        class GVAR(toggleDisplay) {
            displayName = CSTRING(ActionShowContacts);
            icon = ICON_TOGGLE;
            statement = QUOTE(call FUNC(toggleDisplay));
            condition = QUOTE(GVAR(enabled));
            modifierFunction = QUOTE([_this select 0] call FUNC(displayActionModifier));
            priority = 2;
        };
    };
};
