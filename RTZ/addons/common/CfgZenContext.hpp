// Shared parent submenu anchors for every RTZ context action. These live in
// rtz_common (loaded before every feature addon) because ZEN compiles
// zen_context_menu_actions from configFile at preInit, and all scripted
// zen_context_menu_fnc_addAction calls across the RTZ addons target these
// parent paths — addAction logs an error and drops the action if the parent
// node is missing. Feature-addon actions are declared in each addon's own
// CfgContext.hpp (or registered at runtime); only rtz_common's own actions
// hang off the anchors here.
class zen_context_menu_actions {
    // Primary submenu for RTS-style order actions (reload, attack, assemble, ...).
    class RTZ_RealTimeZeus {
        displayName = "Real-Time Zeus";
        icon = "\a3\Ui_F_Curator\Data\Logos\arma3_curator_eye_256_ca.paa";
        priority = 3;

        // Deploy countermeasures: fires the smoke launcher / flare / chaff
        // dispenser of every selected vehicle that has one. The condition
        // carries the QGVAR(enableDeploySmoke) master switch, so the setting
        // can be toggled mid-mission.
        class GVAR(deploySmoke) {
            displayName = CSTRING(ActionDeploySmoke);
            icon = ICON_SMOKE;
            statement = QUOTE([ARR_2(_objects,_hoveredEntity)] call FUNC(orderDeploySmoke));
            condition = QUOTE([ARR_2(_objects,_hoveredEntity)] call FUNC(canDeploySmoke));
            priority = 1;
        };
    };

    // Submenu for the toggleable draw overlays (vehicle tags, unit tags,
    // destinations, targets).
    class RTZ_Overlays {
        displayName = "Overlays";
        icon = "\a3\ui_f\data\igui\cfg\simpletasks\types\documents_ca.paa";
        priority = 6;
    };

    // Submenu for squad/behaviour control actions (behaviour info, disable
    // simulation, LAMBS reset).
    class RTZ_Control {
        displayName = "Controls";
        icon = "\a3\ui_f\data\igui\cfg\simpletasks\types\help_ca.paa";
        priority = 7;
    };
};
