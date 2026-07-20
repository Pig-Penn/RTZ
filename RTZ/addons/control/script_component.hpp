#define COMPONENT control
#define COMPONENT_BEAUTIFIED Control
#include "\x\rtz\addons\main\script_mod.hpp"

// #define DEBUG_MODE_FULL
// #define DISABLE_COMPILE_CACHE

#ifdef DEBUG_ENABLED_CONTROL
    #define DEBUG_MODE_FULL
#endif

#ifdef DEBUG_SETTINGS_CONTROL
    #define DEBUG_SETTINGS DEBUG_SETTINGS_CONTROL
#endif

#include "\x\rtz\addons\main\script_macros.hpp"

// Toggle icon/tint pair for the "Disable/Enable Simulation" context action and
// its modifierFunction.
#define ICON_HIDE "\x\rtz\addons\control\ui\pause_ca.paa"
#define ICON_SHOW "\x\rtz\addons\control\ui\play_ca.paa"
#define COLOR_HIDE [1.00, 0.60, 0.20, 1]
#define COLOR_SHOW [0.40, 1.00, 0.40, 1]

#define ICON_RESET "\a3\3DEN\Data\CfgWaypoints\cycle_ca.paa"
#define ICON_RELOAD "\A3\ui_f\data\igui\cfg\simpletasks\types\rearm_ca.paa"
