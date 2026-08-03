class zen_context_menu_actions {
    // Deploy countermeasures: fires the smoke launcher / flare / chaff
    // dispenser of every selected vehicle that has one. The condition
    // carries the QGVAR(enabled) master switch, so the setting can be
    // toggled mid-mission. Sits at the menu ROOT alongside the other
    // RTS-style order actions (reload, attack, assemble, ...) — it hangs off
    // no submenu, so this component needs none of rtz_common's parent anchors.
    class GVAR(deploySmoke) {
        displayName = CSTRING(ActionDeploySmoke);
        icon = ICON_SMOKE;
        statement = QUOTE([ARR_2(_objects,_hoveredEntity)] call FUNC(orderDeploySmoke));
        condition = QUOTE([ARR_2(_objects,_hoveredEntity)] call FUNC(canDeploySmoke));
        priority = 1;
    };
};
