// Shared parent submenu anchors for every RTZ context action. These live in
// rtz_common (loaded before every feature addon) because ZEN compiles
// zen_context_menu_actions from configFile at preInit, and all scripted
// zen_context_menu_fnc_addAction calls across the RTZ addons target these
// parent paths — addAction logs an error and drops the action if the parent
// node is missing. The actions themselves are registered at runtime by each
// feature addon, so these classes intentionally define no children.
class zen_context_menu_actions {
    // Primary submenu for RTS-style order actions (reload, attack, assemble, ...).
    class RTZ_RealTimeZeus {
        displayName = "Real-Time Zeus";
        icon = "\a3\Ui_F_Curator\Data\Logos\arma3_curator_eye_256_ca.paa";
        priority = 3;
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
        displayName = "Control";
        icon = "\a3\ui_f\data\igui\cfg\simpletasks\types\help_ca.paa";
        priority = 7;
    };
};
