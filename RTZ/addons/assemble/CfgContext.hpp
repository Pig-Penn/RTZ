class zen_context_menu_actions {
    // Both actions sit at the root of the context menu rather than under a RTZ
    // submenu, and both resolve the selection through FUNC(canAssemble) /
    // FUNC(canDisassemble) — which also carry the GVAR(enabled) master switch, so
    // the condition string stays a plain function call (see rtz_mine).
    //
    // No icon property: the cog's path can't be hardcoded (see script_component.hpp),
    // so modifierFunction stamps the live-resolved GVAR(icon) into the action's icon
    // slot each time the menu opens. ZEN runs modifierFunction on a copy of the
    // action before evaluating the condition, and the renderer reads the icon back
    // out of that copy (zen_context_menu_fnc_getActiveActions / fnc_createContextGroup).
    class GVAR(assemble) {
        displayName = CSTRING(ActionAssemble);
        iconColor[] = COLOR_ACTION;
        statement = QUOTE([_objects] call FUNC(orderAssemble));
        condition = QUOTE([_objects] call FUNC(canAssemble));
        modifierFunction = QUOTE((_this select 0) set [ARR_2(ACTION_INDEX_ICON,GVAR(icon))]);
        priority = 45;
    };

    class GVAR(disassemble) {
        displayName = CSTRING(ActionDisassemble);
        iconColor[] = COLOR_ACTION;
        statement = QUOTE([_objects] call FUNC(orderDisassemble));
        condition = QUOTE([_objects] call FUNC(canDisassemble));
        modifierFunction = QUOTE((_this select 0) set [ARR_2(ACTION_INDEX_ICON,GVAR(icon))]);
        priority = 44;
    };
};
