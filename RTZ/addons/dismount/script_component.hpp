#define COMPONENT dismount
#define COMPONENT_BEAUTIFIED Dismount
#include "\x\rtz\addons\main\script_mod.hpp"

// #define DEBUG_MODE_FULL
// #define DISABLE_COMPILE_CACHE

#ifdef DEBUG_ENABLED_DISMOUNT
    #define DEBUG_MODE_FULL
#endif

#ifdef DEBUG_SETTINGS_DISMOUNT
    #define DEBUG_SETTINGS DEBUG_SETTINGS_DISMOUNT
#endif

#include "\x\rtz\addons\main\script_macros.hpp"

// Indices into ZEN's compiled action array, which modifierFunction receives:
// [name, displayName, icon, iconColor, statement, condition, args, insertChildren, modifierFunction]
#define ACTION_INDEX_DISPLAYNAME 1
#define ACTION_INDEX_ICON 2
#define ACTION_INDEX_ICONCOLOR 3

// Toggle icon/tint pair for the "Forbid/Allow Dismount" context action and its
// modifierFunction — amber padlock while vanilla (will lock crew in), cyan
// unlock once locked (will release).
#define ICON_LOCKED "\a3\modules_f\data\iconlock_ca.paa"
#define ICON_UNLOCKED "\a3\modules_f\data\iconunlock_ca.paa"
#define COLOR_LOCKED [1.00, 0.78, 0.22, 1]
#define COLOR_UNLOCKED [0.40, 0.80, 1.00, 1]
