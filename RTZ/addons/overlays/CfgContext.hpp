class zen_context_menu_actions {
    // Both are master switches: while ON, the overlay follows the curator's
    // live selection instead of the current context-menu selection, so the
    // condition is a plain setting check rather than an object test.
    class RTZ_Overlays {
        class GVAR(toggleDestination) {
            displayName = CSTRING(ActionDrawDestinations);
            icon = "\a3\ui_f\data\igui\cfg\simpletasks\types\move_ca.paa";
            statement = QUOTE(call FUNC(destinationToggle));
            condition = QUOTE(GVAR(enableDestinationDisplay));
            modifierFunction = QUOTE([_this select 0] call FUNC(destinationActionModifier));
            priority = 4;
        };

        class GVAR(toggleTarget) {
            displayName = CSTRING(ActionDrawTargets);
            icon = "\a3\ui_f\data\igui\cfg\simpletasks\types\kill_ca.paa";
            statement = QUOTE(call FUNC(targetToggle));
            condition = QUOTE(GVAR(enableTargetDisplay));
            modifierFunction = QUOTE([_this select 0] call FUNC(targetActionModifier));
            priority = 3;
        };
    };
};
