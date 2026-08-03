#define COMPONENT captive
#define COMPONENT_BEAUTIFIED Captive
#include "\x\rtz\addons\main\script_mod.hpp"

// #define DEBUG_MODE_FULL
// #define DISABLE_COMPILE_CACHE

#ifdef DEBUG_ENABLED_CAPTIVE
    #define DEBUG_MODE_FULL
#endif

#ifdef DEBUG_SETTINGS_CAPTIVE
    #define DEBUG_SETTINGS DEBUG_SETTINGS_CAPTIVE
#endif

#include "\x\rtz\addons\main\script_macros.hpp"

// ZEN action array indices (ACTION_INDEX_*) come from main/script_macros.hpp.

// Surrender toggle icon/tint — white pause while fighting (will surrender),
// green/grey play once surrendered (will stand down, grey while lock-timed).
#define ICON_SURRENDER "\x\rtz\addons\captive\ui\pause_ca.paa"
#define ICON_STANDDOWN "\x\rtz\addons\captive\ui\play_ca.paa"
#define COLOR_SURRENDER [1.00, 1.00, 1.00, 1]
#define COLOR_STANDDOWN [0.40, 1.00, 0.40, 1]
#define COLOR_LOCKED [0.55, 0.55, 0.55, 1]

// Capture watch tick. Two seconds is the coarsest rate that still feels
// immediate to a curator watching his squad walk up to a prisoner, and the
// engine only exists while somebody is actually surrendered (see
// FUNC(registerSurrender) / FUNC(captureTick)), so this is not an idle cost.
#define CAPTURE_INTERVAL 2

// getFriend below this counts as hostile — the same threshold the engine uses
// to decide whether two sides shoot at each other.
#define HOSTILE_THRESHOLD 0.6

// The sides a man-class group can plausibly belong to. Resolved to a hostile
// subset once per prisoner so the proximity scan tests membership in a
// four-entry array instead of paying a getFriend call per nearby man.
#define MAN_SIDES [west, east, resistance, civilian]

// The resting hands-up animation state. animationState returns lowercase, so
// this is the form to COMPARE against; the transition below is what gets played
// to enter it.
#define ANIM_SURRENDER_STATE "amovpercmstpssurwnondnon"
#define ANIM_SURRENDER_ENTER "AmovPercMstpSnonWnonDnon_AmovPercMstpSsurWnonDnon"

// Can this object be put into (or taken out of) a scripted surrender? Shared by
// the context condition, the selection collector, the action modifier and the
// authoritative apply guard, so the four can never drift apart.
//
// A macro rather than a function on purpose: this runs per selected object on
// every single context-menu open — ZEN evaluates the modifier AND the condition
// each time the menu is built — and a function call per unit is the one cost
// here worth not paying.
//
// AI only (the apply event lands on the unit's own machine, so a player would
// have his controls seized), alive, conscious, on foot (a seated unit cannot be
// posed with its hands up), and never a unit already taken prisoner — capture is
// permanent. The isKindOf test is load-bearing, not decorative: without it a
// selected VEHICLE passes every remaining check (it is alive, is not a player,
// has no objectParent) and would be handed to setCaptive. Callers must still
// screen for `isEqualType objNull` first — a hovered group or waypoint reaches
// these code paths and isKindOf would type-error on it.
#define CAN_SURRENDER(unit) ( \
    unit isKindOf "CAManBase" \
    && {alive unit} \
    && {!isPlayer unit} \
    && {lifeState unit isNotEqualTo "INCAPACITATED"} \
    && {isNull objectParent unit} \
    && {!(unit getVariable [QGVAR(captured), false])} \
)
