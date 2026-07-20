#define COMPONENT reverse
#define COMPONENT_BEAUTIFIED Reverse
#include "\x\rtz\addons\main\script_mod.hpp"

// #define DEBUG_MODE_FULL
// #define DISABLE_COMPILE_CACHE

#ifdef DEBUG_ENABLED_REVERSE
    #define DEBUG_MODE_FULL
#endif

#ifdef DEBUG_SETTINGS_REVERSE
    #define DEBUG_SETTINGS DEBUG_SETTINGS_REVERSE
#endif

#include "\x\rtz\addons\main\script_macros.hpp"

// Cursor must be at least this far behind the vehicle for an order to be accepted (meters)
#define MIN_DISTANCE 3

// A reverse maneuver completes within this distance of the destination (meters)
#define ARRIVAL_DISTANCE 4

// AI cannot be commanded to drive backward, so the maneuver is driven
// directly via setVelocity at this speed (km/h)
#define REVERSE_SPEED 10

// Speed below which a vehicle counts as not moving (km/h) and how long
// it may stay that slow before the maneuver is aborted as stuck (seconds)
#define STUCK_SPEED 1
#define STUCK_TIME 5

// Order feedback drawing
#define HINT_DURATION 3
#define ICON_MOVE "\a3\ui_f\data\igui\cfg\simpletasks\types\walk_ca.paa"
#define COLOR_INVALID [0.9, 0.2, 0.2, 1]
