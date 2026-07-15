// Parent submenu anchor for every RTZ context action. This MUST stay in config:
// ZEN compiles zen_context_menu_actions from configFile at preInit, and all
// scripted zen_context_menu_fnc_addAction calls across rtz_context /
// rtz_selection / rtz_officer target the ["RTZ_RealTimeZeus"] parent path —
// addAction logs an error and drops the action if the parent node is missing.
// The actions themselves are registered at runtime (see the *Context functions),
// so this class intentionally defines no children.
class zen_context_menu_actions {
    class RTZ_RealTimeZeus {
        displayName = "Real-Time Zeus";
        icon = "\a3\Ui_F_Curator\Data\Logos\arma3_curator_eye_256_ca.paa";
        priority = 3;
    };

    // Root-level submenu anchor for the toggleable draw overlays (vehicle tags,
    // unit tags, destinations, targets). A category-only node with no statement;
    // the actions themselves are registered at runtime against ["RTZ_Overlays"].
    class RTZ_Overlays {
        displayName = "Overlays";
        icon = "\a3\ui_f\data\igui\cfg\simpletasks\types\documents_ca.paa";
        priority = 6;
    };

    // Root-level submenu anchor for squad/behavior control actions (behavior
    // info, disable simulation, LAMBS reset). Same pattern as RTZ_Overlays above;
    // actions register at runtime against ["RTZ_Control"].
    class RTZ_Control {
        displayName = "Control";
        icon = "\a3\ui_f\data\igui\cfg\simpletasks\types\help_ca.paa";
        priority = 7;
    };
};
