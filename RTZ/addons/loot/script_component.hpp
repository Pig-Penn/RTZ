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

// Which body slot a weapon category belongs to, as stored in GVAR(ranks). Kept as
// numbers rather than the engine's CfgWeapons "type" flags on purpose: a handful of
// mods declare `type` as a STRING, where getNumber quietly returns 0 and the weapon
// falls out of every slot test. The category comes from FUNC(itemCategory), which
// reads the cursor instead, so the slot is derived without ever touching that field.
#define SLOT_PRIMARY 0
#define SLOT_LAUNCHER 1
#define SLOT_HANDGUN 2

// Where a claimant is sent to stand: APPROACH_DISTANCE meters out from the target,
// the first on his own side and each further co-claimant an EVEN SHARE of the circle
// around it, so a shared target is ringed rather than mobbed on one point. The share
// is computed from the live claimant cap rather than a fixed bearing - a fixed 120
// degrees, which this used to use, put the fourth claimant back on the first one's
// spot the moment scarce targets pushed the cap past three.
#define APPROACH_DISTANCE 1.2

// How close the unit must get to that spot before he is counted as arrived (meters).
// Measured to the approach point, so the worst-case standoff from the target itself
// is APPROACH_DISTANCE + ARRIVE_DISTANCE - still inside the engine's reach for the
// "TakeWeapon" / "TakeItem" / "rearm" actions
#define ARRIVE_DISTANCE 2

// Walk timeout: WALK_TIMEOUT_BASE seconds plus WALK_TIMEOUT_PER_METER per meter of
// the initial distance. On expiry the unit abandons the errand and rejoins
// formation, so nothing pathfinds forever into an unreachable target
#define WALK_TIMEOUT_BASE 12
#define WALK_TIMEOUT_PER_METER 0.5

// One step of a loot plan gives up after STEP_TIMEOUT seconds. Steps are verified by
// STATE (did the weapon actually land in the slot?) rather than by waiting out a
// fixed delay, so a quick pickup chains on immediately and only a genuinely stuck one
// pays the full timeout. On expiry the step applies its result directly instead of
// stalling the queue - see FUNC(lootStep)
#define STEP_TIMEOUT 4

// Dwell for the steps that have no engine take action to animate (vest, headgear,
// backpack) and for the terminal rearm, which reports no completion of its own
#define STEP_DWELL 1.5

// The unit gave up on the target if he ends up this far from it mid-queue - blown
// clear, or shoved off by a co-claimant's pathing
#define TARGET_ABORT_DISTANCE 8

// How long a lootable scan result stays reusable (seconds). The context menu
// condition re-scans on every right-click and the server re-scans when the order
// lands; at this length a curator cannot outrun the memo, and nothing looted in the
// meantime can go stale enough to matter
#define SCAN_CACHE_TTL 0.5

// Entries the scan memo may hold before it is thrown away wholesale. Everything in it
// is stale by the time it grows this far, so a reset costs nothing and is cheaper
// than evicting entry by entry
#define SCAN_CACHE_MAX 64

// How many candidate targets a unit is planned against before he is given up on.
// Dispatch asks FUNC(lootPlan) whether a unit would actually take anything from a
// target rather than trusting the scan filter, and without a bound a body-strewn
// field would turn that into a full units-by-targets cross product
#define PLAN_ATTEMPTS 3

// Context menu action
#define ICON_ACTION "\a3\ui_f\data\igui\cfg\actions\gear_ca.paa"
