#define COMPONENT attack
#define COMPONENT_BEAUTIFIED Attack
#include "\x\rtz\addons\main\script_mod.hpp"

// #define DEBUG_MODE_FULL
// #define DISABLE_COMPILE_CACHE

#ifdef DEBUG_ENABLED_ATTACK
    #define DEBUG_MODE_FULL
#endif

#ifdef DEBUG_SETTINGS_ATTACK
    #define DEBUG_SETTINGS DEBUG_SETTINGS_ATTACK
#endif

#include "\x\rtz\addons\main\script_macros.hpp"

// Radius around the cursor position in which targets are looked up (meters)
#define SEARCH_RADIUS 25

// How accurately the ordered group knows the revealed target (0..4)
#define REVEAL_ACCURACY 4

// Sides are hostile below this getFriend value (engine threshold)
#define HOSTILE_THRESHOLD 0.6

// Order feedback drawing
#define HINT_DURATION 3
#define ICON_ATTACK "\a3\ui_f\data\igui\cfg\simpleTasks\types\attack_ca.paa"
#define COLOR_TARGET [0.9, 0.2, 0.2, 1]
#define COLOR_INVALID [0.5, 0.5, 0.5, 0.8]
