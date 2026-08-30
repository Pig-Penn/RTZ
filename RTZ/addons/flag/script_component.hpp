#define COMPONENT flag
#define COMPONENT_BEAUTIFIED Flag
#include "\x\rtz\addons\main\script_mod.hpp"

// #define DEBUG_MODE_FULL
// #define DISABLE_COMPILE_CACHE

#ifdef DEBUG_ENABLED_FLAG
    #define DEBUG_MODE_FULL
#endif

#ifdef DEBUG_SETTINGS_FLAG
    #define DEBUG_SETTINGS DEBUG_SETTINGS_FLAG
#endif

#include "\x\rtz\addons\main\script_macros.hpp"

// ZEN's own flag icon, borrowed rather than copied — ZEN is a hard dependency
// (zen_context_menu is in requiredAddons), and vanilla ships no flag under
// \a3\ui_f\...\simpleTasks\types. Same borrow rtz_control makes for
// ICON_OWNERSHIP; note the prefix is x\zen, per ZEN's own $PBOPREFIX$.
#define ICON_FLAG "\x\zen\addons\modules\ui\flag_ca.paa"
