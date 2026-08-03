class zen_context_menu_actions {
    // Sits under the shared RTZ_Overlays submenu (declared in
    // rtz_common/CfgZenContext.hpp) alongside the other toggleable draw
    // overlays. Master switch for the individual spotted-unit chevrons (pass 2
    // of FUNC(drawSpots)), PER-CLIENT — group icons (pass 1) are
    // unaffected, so the condition is a plain setting check rather than an
    // object test.
    class RTZ_Overlays {
        class GVAR(toggleChevrons) {
            displayName = CSTRING(ActionShowChevrons);
            icon = ICON_TOGGLE_CHEVRONS;
            statement = QUOTE(call FUNC(toggleChevrons));
            condition = QUOTE(GVAR(enableSpottingSystem));
            modifierFunction = QUOTE([_this select 0] call FUNC(chevronsActionModifier));
            priority = 1;
        };
    };
};
