class Extended_PreStart_EventHandlers {
    class ADDON {
        init = QUOTE(call COMPILE_SCRIPT(XEH_preStart));
    };
};
class Extended_PreInit_EventHandlers {
    class ADDON {
        init = QUOTE(call COMPILE_SCRIPT(XEH_preInit));
    };
};
class Extended_PostInit_EventHandlers {
    class ADDON {
        init = QUOTE(call COMPILE_SCRIPT(XEH_postInit));
    };
};
// Fires each time the Zeus display is created (it is destroyed and recreated on every
// open) — re-attaches the aura-zone map overlay to the fresh map control. _this = [display].
class Extended_DisplayLoad_EventHandlers {
    class RscDisplayCurator {
        ADDON = QUOTE(call FUNC(initCuratorDisplay));
    };
};
