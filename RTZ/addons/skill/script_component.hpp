#define COMPONENT skill
#define COMPONENT_BEAUTIFIED Skill
#include "\x\rtz\addons\main\script_mod.hpp"

// #define DEBUG_MODE_FULL
// #define DISABLE_COMPILE_CACHE

#ifdef DEBUG_ENABLED_SKILL
    #define DEBUG_MODE_FULL
#endif

#ifdef DEBUG_SETTINGS_SKILL
    #define DEBUG_SETTINGS DEBUG_SETTINGS_SKILL
#endif

#include "\x\rtz\addons\main\script_macros.hpp"

// Sentinel returned by the skill table for classes without an entry
#define SKILL_NONE -1
