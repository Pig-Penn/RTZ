#define COMPONENT airstrike
#define COMPONENT_BEAUTIFIED Airstrike
#include "\x\rtz\addons\main\script_mod.hpp"

// #define DEBUG_MODE_FULL
// #define DISABLE_COMPILE_CACHE

#ifdef DEBUG_ENABLED_AIRSTRIKE
    #define DEBUG_MODE_FULL
#endif

#ifdef DEBUG_SETTINGS_AIRSTRIKE
    #define DEBUG_SETTINGS DEBUG_SETTINGS_AIRSTRIKE
#endif

#include "\x\rtz\addons\main\script_macros.hpp"

// The aim session's target ring and approach arrow draw through rtz_core's ONE
// Draw3D handler, so this component needs that contract (RENDER_WORLD, CTX_*).
#include "\x\rtz\addons\core\script_macros_core.hpp"

// ── What kind of ordnance ────────────────────────────────────────────────────
// Decided ONCE per weapon by FUNC(strikeWeapons) and carried in the menu row,
// because it selects the release range, the aim offset and the shot cap. Stored
// as a number rather than the raw BIS_fnc_itemType string so nothing downstream
// does string comparison on a per-tick path.
#define TYPE_GUN     0
#define TYPE_ROCKET  1
#define TYPE_MISSILE 2
#define TYPE_BOMB    3

// Slant range at which each type releases (meters), indexed by TYPE_*. A bomb
// wants a long, high release and a gun run wants a short one — which is the whole
// reason the weapon is chosen BEFORE the bearing is drawn rather than after.
#define RELEASE_RANGE [700, 900, 1500, 1200]

// Vertical fudge added to the aim point, indexed by TYPE_*. A guided missile aimed
// at a point on the deck noses into the dirt short of it; every other type wants
// the aim point where it was drawn. ZEN's CAS module applies the same 20 m to its
// missile type and nothing to the rest.
#define AIM_OFFSET [0, 0, 20, 0]

// ── Run-in geometry ──────────────────────────────────────────────────────────
// Wargame's plane figures (jac_fnc_tacticalAirSupport).
#define RUN_IN_DISTANCE   1500   // m from the aim point back to the run-in start
#define RUN_IN_ALTITUDE    750   // m above terrain at the run-in start
#define RUN_IN_CAPTURE     150   // m — close enough to drop onto the rail
#define HEADING_TOLERANCE   15   // deg — aligned enough to drop onto the rail
#define EGRESS_DISTANCE   4000   // m beyond the aim point
#define FLY_HEIGHT_MIN     150   // m — floor for the flyInHeight handed back on egress

// ── Ingress steering ─────────────────────────────────────────────────────────
// This replaces Wargame's precomputed parabolic approach paths entirely. A target
// behind the aircraft produces a reversal because the rotation simply takes
// longer — there is no turnaround case to detect and no path to build.
#define TURN_RATE           12   // deg/s cap. 12 is a 30-second full circle:
                                 // chosen for readable Zeus-scale movement rather
                                 // than for realism. The most likely constant to
                                 // need retuning after in-game test 2.
#define BANK_MAX            60   // deg of roll at full turn rate
#define CLIMB_MAX           30   // deg of pitch during ingress, so a run-in start
                                 // far above the aircraft does not stand it on its tail
#define MAX_DELTA          0.5   // s — a frame hitch or a mission-time jump must not
                                 // be handed to the steering as one enormous turn

// Cruise is derived from the aircraft's OWN config maxSpeed, not a flat figure:
// a Buzzard and a Caesar BTT have no business flying the same rail. CRUISE_COEF is
// Wargame's ATTACK-RUN fraction (maxSpeedOG * 0.5), not its lower approach one — at
// 0.25 a light propeller aircraft comes out at a walking pace and only the floor
// rescues it, which would make the floor rather than the aircraft decide its speed.
#define CRUISE_COEF        0.5
#define CRUISE_MIN          40   // m/s floor

// ── Firing ───────────────────────────────────────────────────────────────────
// ZEN CAS module figures, except MAX_SHOTS which is Wargame's.
#define FIRE_DURATION        3   // s the firing window stays open
#define FIRE_DELAY         0.1   // s between fireAtTarget calls
#define AIM_RAISE           12   // m the aim point rises across the firing window,
                                 // which walks the burst instead of stacking every
                                 // round on one spot
#define MAX_SHOTS           26   // capped to 1 instead when weaponLockSystem != 0

// ── Deadlines ────────────────────────────────────────────────────────────────
// Every phase is bounded and the whole strike is bounded. A wedged strike must not
// be able to hold the per-frame handler for the rest of a multi-hour operation.
#define INGRESS_TIMEOUT    120
#define RUN_TIMEOUT         40
#define EGRESS_TIMEOUT      15
#define STRIKE_TIMEOUT     180
#define CHECK_INTERVAL    0.25   // s — throttle for the abort conditions

// ── Aim session ──────────────────────────────────────────────────────────────
#define MIN_AIM_DRAG        25   // m of world drag below which the bearing falls back
                                 // to the aircraft's current heading, so the gesture
                                 // degrades gracefully to a plain click
#define AIM_RING_RADIUS     40   // m — radius of the drawn target ring
#define AIM_RING_SEGMENTS   24
#define AIM_ARROW_LENGTH   400   // m — how far the drawn approach arrow extends
#define AIM_VALID_INTERVAL 0.2   // s — how often FUNC(drawAim) re-checks whether
                                 // the order would still be accepted, rather than
                                 // re-running that walk every frame the ring is up

#define HINT_DURATION        4
#define HINT_ARROW         300   // m — length of the confirmation hint's approach line

#define ICON_STRIKE   "\a3\ui_f\data\igui\cfg\simpleTasks\types\destroy_ca.paa"
#define COLOR_STRIKE  [0.9, 0.5, 0.1, 1]
#define COLOR_INVALID [0.9, 0.2, 0.2, 1]

// ── Phases ───────────────────────────────────────────────────────────────────
// Three, not four: FIRING is a flag inside the run rather than a phase of its own,
// because the rail has to keep driving the aircraft while it shoots. Splitting them
// would leave two things owning the hull's velocity at once.
#define PHASE_INGRESS 0
#define PHASE_RUN     1
#define PHASE_EGRESS  2

// ── Layout of a strike record in GVAR(active) ────────────────────────────────
// One entry per aircraft striking on THIS machine. Written by FUNC(executeStrike),
// driven by FUNC(strikeTick), torn down by FUNC(endStrike) and by nothing else.
//
// DRIVER is the load-bearing one: the unit whose AI this strike actually disabled,
// remembered so teardown restores THAT unit rather than whoever occupies the seat
// when it ends. Same reasoning as rtz_slide's MANEUVER_DRIVER.
#define STRIKE_PLANE     0
#define STRIKE_DRIVER    1
#define STRIKE_AIM       2   // aim point, ASL
#define STRIKE_BEARING   3   // direction of FLIGHT, degrees
#define STRIKE_WEAPON    4   // [weapon, turretPath, type]
#define STRIKE_PHASE     5
#define STRIKE_START     6   // run-in start point, ASL
#define STRIKE_RESTORE   7   // [moveAI, targetAI, autoTargetAI, behaviour, combatMode]
#define STRIKE_RAIL      8   // [origin, velocity, vectorDir, vectorUp, t0, duration]
#define STRIKE_LASER     9   // objNull until the firing window opens
#define STRIKE_SHOTS    10
#define STRIKE_NEXTFIRE 11
#define STRIKE_PHASE_AT 12   // deadline for the CURRENT phase
#define STRIKE_DEADLINE 13   // hard deadline for the whole strike
#define STRIKE_CHECK    14   // next throttled-condition time
#define STRIKE_CRUISE   15   // m/s, derived once at order time
#define STRIKE_PROGRESS 16   // 0..1 fire progress, drives the rail's aim raise
#define STRIKE_FIRE_END 17   // absolute time the firing window closes
#define STRIKE_FIRE_DONE 18  // the window has closed and must not reopen. FUNC(release)
                             // reports this; without somewhere to keep it the rail would
                             // call it again on the very next frame and go on firing at
                             // FIRE_DELAY for the rest of the run, past both FIRE_DURATION
                             // and the shot cap.
