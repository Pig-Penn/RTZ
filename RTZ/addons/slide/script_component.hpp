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

// A reverse maneuver completes within this distance of the destination (meters).
// Only a backstop for lateral drift — the abeam test in FUNC(reverseTick) is the
// exact stop condition, so this can stay tight.
#define ARRIVAL_DISTANCE 2

// Cursor must be at least this far behind the vehicle for an order to be
// accepted (meters). MUST stay comfortably above ARRIVAL_DISTANCE: a destination
// inside the arrival radius is one the vehicle has already reached, so the
// maneuver would set up, complete and tear down on its first tick without ever
// moving. It also leaves margin for the position disagreement between the
// curator's client, which picks the destination, and the vehicle's owner, which
// drives to it.
#define MIN_DISTANCE 6

// AI cannot be commanded to drive backward, so the maneuver is driven directly
// via setVelocity at this speed. Authored in km/h to read like a speedometer,
// used in m/s because that is the unit setVelocity takes.
#define REVERSE_SPEED 10
#define REVERSE_SPEED_MS (REVERSE_SPEED / 3.6)

// Speed below which a vehicle counts as not moving (km/h) and how long
// it may stay that slow before the maneuver is aborted as stuck (seconds)
#define STUCK_SPEED 1
#define STUCK_TIME 5

// How often FUNC(reverseTick) re-runs the conditions that abort a maneuver.
// Only the velocity push and the arrival test run every frame; everything else
// changes on human timescales and is throttled to this instead.
#define CHECK_INTERVAL 0.25

// Order feedback drawing. The destination icon is ZEN's expected-destination
// texture — the same glyph rtz_common's teleport draws for a move order, which
// is what this is: a destination, not a man on foot.
#define HINT_DURATION 3
#define ICON_MOVE "\a3\ui_f\data\igui\cfg\simpleTasks\types\move_ca.paa"
#define COLOR_INVALID [0.9, 0.2, 0.2, 1]

// Layout of a maneuver record in GVAR(active) — one entry per vehicle currently
// reversing on this machine. Written by FUNC(reverseTo), driven by
// FUNC(reverseTick), torn down by FUNC(endReverse).
//
// DRIVER is the load-bearing one: the unit whose MOVE/PATH this maneuver
// actually disabled, remembered so teardown restores THAT unit rather than
// whoever happens to be sitting in the seat when the maneuver ends.
// AXIS is the ground-plane rear direction captured at order time, so the slide
// holds the straight line the curator was shown even as the hull yaws under it.
#define MANEUVER_VEHICLE 0
#define MANEUVER_DRIVER 1
#define MANEUVER_AXIS 2
#define MANEUVER_DESTINATION 3
#define MANEUVER_END_TIME 4
#define MANEUVER_MOVED_AT 5
#define MANEUVER_CHECK_AT 6
