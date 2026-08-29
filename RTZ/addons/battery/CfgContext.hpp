class zen_context_menu_actions {
    // The replacement for ZEN's own FireArtillery entry, which rtz_common's
    // Clean Context Menu removes. Same icon, same priority 70 — free at RTZ's
    // root (attack 80, smoke 69), so the entry lands exactly where the removed
    // one was — but the target is picked with the cursor and then handed to
    // ZEN's Fire Mission dialog, instead of firing a fixed four rounds at zero
    // spread from a magazine chosen out of a submenu.
    //
    // Root level rather than under RTZ_Control: this is an order, and every RTZ
    // order (attack, airstrike, assemble, resupply) sits at the root.
    class GVAR(fireMission) {
        displayName = CSTRING(ActionFireMission);
        icon = ICON_FIREMISSION;
        statement = QUOTE([_objects] call FUNC(selectFireMission));
        condition = QUOTE([_objects] call FUNC(canFireMission));
        priority = 70;
    };

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
