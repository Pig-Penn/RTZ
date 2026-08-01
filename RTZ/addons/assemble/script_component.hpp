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

// Fallback clean-up radii, both in meters, used only when the engine assemble ran
// half way (see FUNC(buildWeapon)). ADOPT_RADIUS is how far out the fallback looks
// for a static the engine already raised before deciding to raise its own;
// BAG_SWEEP_RADIUS is how far out it looks for the support bag the engine's "PutBag"
// half dropped. Both are deliberately tight - the man they are measured from is
// standing right next to what is being looked for, and nearestObjects returns
// nearest first, so a neighbouring squad's weapon (FAN_DISTANCE apart) never wins
#define ADOPT_RADIUS 5
#define BAG_SWEEP_RADIUS 5

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

// Ghost-model placement preview marker. Matches vanilla Zeus create-menu placement:
// the static's own tree icon (resolved per class in fnc_orderAssemble) drawn plain
// white with no hint text, so the ghost static reads the same as any entry dragged
// out of the curator tree
#define COLOR_PREVIEW [1, 1, 1, 1]
