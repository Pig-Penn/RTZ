#define COMPONENT assemble
#define COMPONENT_BEAUTIFIED Assemble
#include "\x\rtz\addons\main\script_mod.hpp"

// #define DEBUG_MODE_FULL
// #define DISABLE_COMPILE_CACHE

#ifdef DEBUG_ENABLED_ASSEMBLE
    #define DEBUG_MODE_FULL
#endif

#ifdef DEBUG_SETTINGS_ASSEMBLE
    #define DEBUG_SETTINGS DEBUG_SETTINGS_ASSEMBLE
#endif

#include "\x\rtz\addons\main\script_macros.hpp"

// Seconds to wait for the engine's "WeaponAssembled" / "WeaponDisassembled" before
// the deterministic fallback forces the build/pack. Sits comfortably past a normal
// engine animation (~3-4s) so a valid engine run always wins the race
#define BUILD_TIMEOUT 6
#define PACK_TIMEOUT 6

// How close the crew must get to the picked spot before the weapon is raised (meters)
#define ARRIVE_DISTANCE 4

// Walk timeout: WALK_TIMEOUT_BASE seconds plus WALK_TIMEOUT_PER_METER per meter of
// the initial distance. On expiry the errand builds/packs in place, so a Zeus order
// always completes
#define WALK_TIMEOUT_BASE 12
#define WALK_TIMEOUT_PER_METER 0.5

// Multiple ordered squads fan out around the cursor so their weapons don't stack:
// the Nth squad builds FAN_DISTANCE * N meters out, FAN_BEARING * N degrees around
#define FAN_DISTANCE 3
#define FAN_BEARING 60

// Context menu icon: the vanilla curator "module" cog. Its .paa path is resolved
// live from CfgVehicleIcons into GVAR(icon) at preInit rather than hardcoded — that
// class lives in the engine's core bin config rather than any PBO, and ZEN resolves
// the same table live (see zen_common_fnc_getVehicleIcon). Config can't read another
// config entry, so the resolved path is stamped onto both actions by the
// modifierFunction in CfgContext.hpp; only the tint is static config
#define ICON_CONFIG_ENTRY "iconModule"
#define COLOR_ACTION {0.94, 0.51, 0.19, 1}

// Icon slot in ZEN's compiled action array, which modifierFunction receives:
// [name, displayName, icon, iconColor, statement, condition, args, insertChildren, modifierFunction]
#define ACTION_INDEX_ICON 2

// Ghost-model placement preview marker
#define ICON_PREVIEW "\a3\ui_f\data\igui\cfg\actions\repair_ca.paa"
#define COLOR_PREVIEW [0.2, 1, 0.2, 1]
