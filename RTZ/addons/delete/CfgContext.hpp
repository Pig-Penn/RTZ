class zen_context_menu_actions {
    // RTZ_Control is declared in rtz_common (see its CfgZenContext.hpp): the
    // anchor lives there precisely so feature addons can hang actions off it.
    class RTZ_Control {
        // Takes corpses, wrecks and plain objects as well as living units.
        // The condition stops at the first deletable entry (the `true` flag)
        // rather than expanding the whole selection just to test emptiness.
        class GVAR(deleteObjects) {
            displayName = CSTRING(ActionDelete);
            icon = ICON_DELETE;
            statement = QUOTE([ARR_3(_objects,_groups,_hoveredEntity)] call FUNC(orderDelete));
            condition = QUOTE(GVAR(enabled) && {([ARR_3(_objects + [_hoveredEntity],_groups,true)] call FUNC(collectDeletables)) isNotEqualTo []});
            priority = 1;
        };
    };
};
