class zen_context_menu_actions {
    class GVAR(toggle) {
        displayName = CSTRING(ActionShow);
        icon = "\a3\ui_f\data\igui\cfg\simpleTasks\types\car_ca.paa";
        statement = QUOTE(_objects call FUNC(toggleVehicles));
        // GVAR(enabled) is a CBA setting: defined on every machine once settings
        // initialize, well before any context menu can open. GETGVAR must not be
        // used inside QUOTE — its expansion nests double quotes and breaks the
        // config string.
        condition = QUOTE(GVAR(enabled) && {_objects findIf {_x isKindOf 'AllVehicles' && {!(_x isKindOf 'CAManBase')} || {!isNull objectParent _x}} != -1});
        modifierFunction = QUOTE([ARR_2(_this select 0,_objects)] call FUNC(modifyAction));
        priority = 39;
    };
};
