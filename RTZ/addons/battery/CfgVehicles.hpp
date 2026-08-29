class CfgVehicles {
    class zen_modules_moduleBase;

    // FUNC(selectFireMission) creates one of ZEN's own target logics at the picked
    // position, so the fire mission can be aimed at a target module rather than at a
    // grid string rounded to the middle of its square. Creating the module class is
    // what puts the logic in zen_position_logics' target list, which is the only list
    // zen_modules_fnc_gui_fireMission's Target Module combo reads — but it also means
    // ZEN's Create Target dialog (name + attach laser) opens one frame later, which
    // would put a second dialog in front of a curator who asked for one.
    //
    // zen_modules_fnc_initModule resolves a module's function through
    // getText (configOf _logic >> "function"), so the config entry is the only hook —
    // the function itself is compiled final by CBA and cannot be wrapped by
    // reassignment. Exactly the override rtz_restrict installs on ZEN's Arsenal
    // module; see addons/restrict/CfgVehicles.hpp.
    //
    // FUNC(createTarget) delegates to ZEN's function for every logic RTZ did not
    // create, so a curator dragging Create Target out of the module tree still gets
    // the naming dialog.
    class zen_modules_moduleCreateTarget: zen_modules_moduleBase {
        function = QFUNC(createTarget);
    };
};
