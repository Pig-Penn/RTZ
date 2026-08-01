class zen_context_menu_actions {
    // Both are master switches: while ON, the overlay follows the curator's
    // live selection instead of the current context-menu selection, so the
    // condition is a plain setting check rather than an object test. The
    // setting is read LIVE and the machinery is registered unconditionally
    // (see XEH_postInit), so flipping either mid-mission just works.
    //
    // Statement, condition and modifierFunction are the SHARED stream-engine
    // halves parameterised by stream id — a third overlay is one more block
    // here plus a gather/draw pair, not another copy of the machinery.
    class RTZ_Overlays {
        class GVAR(toggleDestination) {
            displayName = CSTRING(ActionDrawDestinations);
            icon = ICON_DEST;
            statement = QUOTE([STREAM_DEST] call FUNC(toggleOverlay));
            condition = QUOTE(GVAR(enableDestinationDisplay));
            modifierFunction = QUOTE([ARR_2(_this select 0,STREAM_DEST)] call FUNC(overlayActionModifier));
            priority = 4;
        };

        class GVAR(toggleTarget) {
            displayName = CSTRING(ActionDrawTargets);
            icon = ICON_TGT;
            statement = QUOTE([STREAM_TGT] call FUNC(toggleOverlay));
            condition = QUOTE(GVAR(enableTargetDisplay));
            modifierFunction = QUOTE([ARR_2(_this select 0,STREAM_TGT)] call FUNC(overlayActionModifier));
            priority = 3;
        };
    };
};
