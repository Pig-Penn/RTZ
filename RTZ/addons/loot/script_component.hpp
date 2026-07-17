#define COMPONENT loot
#define COMPONENT_BEAUTIFIED Loot
#include "\x\rtz\addons\main\script_mod.hpp"

// #define DEBUG_MODE_FULL
// #define DISABLE_COMPILE_CACHE

#ifdef DEBUG_ENABLED_LOOT
    #define DEBUG_MODE_FULL
#endif

#ifdef DEBUG_SETTINGS_LOOT
    #define DEBUG_SETTINGS DEBUG_SETTINGS_LOOT
#endif

#include "\x\rtz\addons\main\script_macros.hpp"

// Where a claimant is sent to stand: APPROACH_DISTANCE meters out from the target,
// the first on his own side and each further co-claimant FAN_BEARING degrees around,
// so a shared target is ringed rather than mobbed on one point
#define APPROACH_DISTANCE 1.2
#define FAN_BEARING 120

// How close the unit must get to that spot before he is counted as arrived (meters).
// Measured to the approach point, so the worst-case standoff from the target itself
// is APPROACH_DISTANCE + ARRIVE_DISTANCE - still inside the engine's reach for the
// "TakeWeapon" / "rearm" actions
#define ARRIVE_DISTANCE 2

// Walk timeout: WALK_TIMEOUT_BASE seconds plus WALK_TIMEOUT_PER_METER per meter of
// the initial distance. On expiry the unit abandons the errand and rejoins
// formation, so nothing pathfinds forever into an unreachable target
#define WALK_TIMEOUT_BASE 12
#define WALK_TIMEOUT_PER_METER 0.5

// Context menu action
#define ICON_ACTION "\a3\ui_f\data\igui\cfg\actions\gear_ca.paa"
