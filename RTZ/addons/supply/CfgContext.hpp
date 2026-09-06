class zen_context_menu_actions {
    // Opens a PICKER (FUNC(orderResupply)): the curator aims at one vehicle and
    // every selected supply vehicle that can do something for it services it,
    // handing over whichever of repair / fuel / ammo it carries. The statement is
    // unchanged from when this order swept everything parked in radius — what
    // FUNC(orderResupply) does with the selection is what changed.
    class GVAR(resupply) {
        displayName = CSTRING(ActionResupply);
        icon = ICON_RESUPPLY;
        statement = QUOTE([_objects] call FUNC(orderResupply));
        condition = QUOTE([_objects] call FUNC(canResupply));
        // Relabels to Repair/Refuel/Rearm (with the matching icon) when every
        // selected supply vehicle offers only that one service.
        modifierFunction = QUOTE([ARR_2(_this select 0,_objects)] call FUNC(resupplyActionModifier));
        priority = 36;
    };

    // NO supply-lines entry in the shared RTZ_Overlays submenu, unlike rtz_hud's
    // destination and target overlays: the lines are ALWAYS drawn, with no context
    // action and no setting behind them, so there is nothing for a curator to
    // switch on. XEH_postInit switches the stream on once and leaves it on.
};
