#define COMPONENT repair
#define COMPONENT_BEAUTIFIED Repair
#include "\x\rtz\addons\main\script_mod.hpp"

// #define DEBUG_MODE_FULL
// #define DISABLE_COMPILE_CACHE

#ifdef DEBUG_ENABLED_REPAIR
    #define DEBUG_MODE_FULL
#endif

#ifdef DEBUG_SETTINGS_REPAIR
    #define DEBUG_SETTINGS DEBUG_SETTINGS_REPAIR
#endif

#include "\x\rtz\addons\main\script_macros.hpp"

// Radius around the context menu position in which a damaged vehicle is looked up (meters)
#define SEARCH_RADIUS 20

// Where an engineer is sent to stand: APPROACH_DISTANCE meters out from the
// vehicle's bounding box, the first on his own side and each further engineer
// FAN_BEARING degrees around it, so a shared vehicle is ringed rather than mobbed
// on one point. Walking at the hull center instead (what this addon used to do)
// makes the engine path engineers INTO the vehicle
#define APPROACH_DISTANCE 1.5
#define FAN_BEARING 90

// How close the engineer must get to that spot before he counts as arrived (meters)
#define ARRIVE_DISTANCE 2.5

// The repair is abandoned once the engineer ends up further than this from the
// vehicle (meters) — he was knocked back, blown clear or otherwise displaced
#define REPAIR_ABORT_DISTANCE 10

// Walk timeout: WALK_TIMEOUT_BASE seconds plus WALK_TIMEOUT_PER_METER per meter of
// the initial distance, floored at the GVAR(repairTimeout) setting. On expiry the
// engineer abandons the errand and rejoins formation, so nothing pathfinds forever
// into an unreachable vehicle
#define WALK_TIMEOUT_BASE 10
#define WALK_TIMEOUT_PER_METER 0.5

// Vehicles below this damage are treated as intact and offer no repair action
#define REPAIR_THRESHOLD 0.05

// Floor (s) of the interval at which repair progress is applied. Deliberately
// coarse: the job interpolates against the clock, so the interval changes write
// granularity, never total repair speed
#define REPAIR_TICK 0.5

// Full-body animation the engineer plays while working on the vehicle
#define REPAIR_ANIMATION "Acts_carFixingWheel"
