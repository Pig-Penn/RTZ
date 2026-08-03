#define COMPONENT casualty
#define COMPONENT_BEAUTIFIED Casualty
#include "\x\rtz\addons\main\script_mod.hpp"

// #define DEBUG_MODE_FULL
// #define DISABLE_COMPILE_CACHE

#ifdef DEBUG_ENABLED_CASUALTY
    #define DEBUG_MODE_FULL
#endif

#ifdef DEBUG_SETTINGS_CASUALTY
    #define DEBUG_SETTINGS DEBUG_SETTINGS_CASUALTY
#endif

#include "\x\rtz\addons\main\script_macros.hpp"

// "Load into Medical Vehicle" context action icon/tint (vanilla NATO medical marker).
// Config array literal (curly braces) — set via iconColor[] in CfgContext.hpp.
#define ICON_LOAD "\a3\ui_f\data\map\markers\nato\n_med.paa"
#define COLOR_LOAD {0.90, 0.20, 0.20, 1}

// 3D casualty indicator marker colours — red while down, blue once loaded
#define COLOR_CASUALTY_DOWN [0.90, 0.15, 0.15, 1]
#define COLOR_CASUALTY_LOADED [0.20, 0.60, 1.00, 1]
