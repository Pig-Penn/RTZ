#define COMPONENT captive
#define COMPONENT_BEAUTIFIED Captive
#include "\x\rtz\addons\main\script_mod.hpp"

// #define DEBUG_MODE_FULL
// #define DISABLE_COMPILE_CACHE

#ifdef DEBUG_ENABLED_CAPTIVE
    #define DEBUG_MODE_FULL
#endif

#ifdef DEBUG_SETTINGS_CAPTIVE
    #define DEBUG_SETTINGS DEBUG_SETTINGS_CAPTIVE
#endif

#include "\x\rtz\addons\main\script_macros.hpp"

// ZEN action array indices (ACTION_INDEX_*) come from main/script_macros.hpp.

// Surrender toggle icon/tint — white pause while fighting (will surrender),
// green/grey play once surrendered (will stand down, grey while lock-timed).
#define ICON_SURRENDER "\x\rtz\addons\captive\ui\pause_ca.paa"
#define ICON_STANDDOWN "\x\rtz\addons\captive\ui\play_ca.paa"
#define COLOR_SURRENDER [1.00, 1.00, 1.00, 1]
#define COLOR_STANDDOWN [0.40, 1.00, 0.40, 1]
#define COLOR_LOCKED [0.55, 0.55, 0.55, 1]
