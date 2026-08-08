#define COMPONENT slide
#define COMPONENT_BEAUTIFIED Slide
#include "\x\rtz\addons\main\script_mod.hpp"

// #define DEBUG_MODE_FULL
// #define DISABLE_COMPILE_CACHE

#ifdef DEBUG_ENABLED_SLIDE
    #define DEBUG_MODE_FULL
#endif

#ifdef DEBUG_SETTINGS_SLIDE
    #define DEBUG_SETTINGS DEBUG_SETTINGS_SLIDE
#endif

#include "\x\rtz\addons\main\script_macros.hpp"

// A "slide" is this component's whole subject: a vehicle driven in a straight
// line by a direct setVelocity push, forward or backward, with its driver taken
// off the AI navigation stack for the duration. It is deliberately NOT the word
// for ordinary vehicle movement — that is rtz_path and rtz_orders, which
// pathfind. The component was called `reverse` until it grew the forward half.

// A maneuver completes within this distance of the destination (meters).
// Only a backstop for lateral drift — the abeam test in FUNC(slideTick) is the
// exact stop condition, so this can stay tight. Kept squared as well because
// that test runs per vehicle per frame and comparing squared lengths avoids the
// square root (and the second position read distance2D would cost).
#define ARRIVAL_DISTANCE 2
#define ARRIVAL_DISTANCE_SQ (ARRIVAL_DISTANCE * ARRIVAL_DISTANCE)

// Cursor must be at least this far ahead of or behind the vehicle for an order
// to be accepted (meters). MUST stay comfortably above ARRIVAL_DISTANCE: a
// destination inside the arrival radius is one the vehicle has already reached,
// so the maneuver would set up, complete and tear down on its first tick without
// ever moving. It also leaves margin for the position disagreement between the
// curator's client, which picks the destination, and the vehicle's owner, which
// drives to it. Applied to the ABSOLUTE projection, so it is equally the dead
// zone abeam of the vehicle where neither direction has an answer.
#define MIN_DISTANCE 6

// AI cannot be commanded to drive backward, so a reverse is driven directly via
// setVelocity. Forward is driven the same way ON PURPOSE rather than handed to
// doMove: the curator is shown a straight line and a distance, and doMove
// answers a different question — it pathfinds, prefers roads, may swing wide or
// turn around, and treats a ten-metre nudge as beneath it. Pathed movement is
// what rtz_path and rtz_orders are for; this keybind is the one that does
// exactly what it drew.
//
// Forward is the faster of the two because a driver reversing is the slower of
// the two. Authored in km/h to read like a speedometer, used in m/s because that
// is the unit setVelocity takes.
#define FORWARD_SPEED 20
#define REVERSE_SPEED 10
#define FORWARD_SPEED_MS (FORWARD_SPEED / 3.6)
#define REVERSE_SPEED_MS (REVERSE_SPEED / 3.6)

// Speed below which a vehicle counts as not moving (km/h) and how long
// it may stay that slow before the maneuver is aborted as stuck (seconds)
#define STUCK_SPEED 1
#define STUCK_TIME 5

// How often FUNC(slideTick) re-runs the conditions that abort a maneuver.
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
// sliding on this machine. Written by FUNC(slideTo), driven by FUNC(slideTick),
// torn down by FUNC(endSlide).
//
// DRIVER is the load-bearing one: the unit whose MOVE/PATH this maneuver
// actually disabled, remembered so teardown restores THAT unit rather than
// whoever happens to be sitting in the seat when the maneuver ends.
// AXIS is the ground-plane direction of TRAVEL captured at order time — the
// hull's facing for a forward order and its negation for a reverse — so the
// slide holds the straight line the curator was shown even as the hull yaws
// under it, and so everything downstream of the order is direction-agnostic.
// SPEED carries which of the two the order was, in m/s, for the same reason: it
// is the only thing the engine needs to know about the direction it is going.
#define MANEUVER_VEHICLE 0
#define MANEUVER_DRIVER 1
#define MANEUVER_AXIS 2
#define MANEUVER_DESTINATION 3
#define MANEUVER_SPEED 4
#define MANEUVER_END_TIME 5
#define MANEUVER_MOVED_AT 6
#define MANEUVER_CHECK_AT 7
