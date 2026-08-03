#define COMPONENT smoke
#define COMPONENT_BEAUTIFIED Smoke
#include "\x\rtz\addons\main\script_mod.hpp"

// #define DEBUG_MODE_FULL
// #define DISABLE_COMPILE_CACHE

#ifdef DEBUG_ENABLED_SMOKE
    #define DEBUG_MODE_FULL
#endif

#ifdef DEBUG_SETTINGS_SMOKE
    #define DEBUG_SETTINGS DEBUG_SETTINGS_SMOKE
#endif

#include "\x\rtz\addons\main\script_macros.hpp"

// Context action icon for the deploy-countermeasures order (ZEN's smoke module texture)
#define ICON_SMOKE "\x\zen\addons\modules\ui\smoke_pillar_ca.paa"
