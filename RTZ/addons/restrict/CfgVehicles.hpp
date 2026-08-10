class CfgVehicles {
    class zen_modules_moduleBase;

    // zen_modules_fnc_initModule resolves a module's function through
    // getText (configOf _logic >> "function"), so overriding that entry is the
    // hook. ZEN's function is compiled final by CBA and cannot be wrapped by
    // reassignment; FUNC(moduleArsenal) delegates to it when allowed.
    class zen_modules_moduleArsenal: zen_modules_moduleBase {
        function = QFUNC(moduleArsenal);
    };
};
