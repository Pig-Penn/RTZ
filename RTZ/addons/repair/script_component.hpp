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

// How close a unit must get to the vehicle before it starts repairing (meters)
#define REPAIR_DISTANCE 6

// The repair is abandoned once the unit ends up further than this from the vehicle (meters)
#define REPAIR_ABORT_DISTANCE 10

// Vehicles below this damage are treated as intact and offer no repair action
#define REPAIR_THRESHOLD 0.05

// Interval at which the vehicle damage is stepped down while repairing (seconds)
#define REPAIR_INTERVAL 0.5

// Full-body animation the engineer plays while working on the vehicle
#define REPAIR_ANIMATION "Acts_carFixingWheel"
