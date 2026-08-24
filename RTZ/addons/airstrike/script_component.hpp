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
// ZEN's CAS module figures (CAS_DISTANCE / CAS_ALTITUDE), not Wargame's. Wargame's
// 1500 m at 750 m is a 26.6-degree dive covered in seven seconds by anything jet-
// powered: the run is over before it reads as a run. The module's proportions give an
// 18-degree dive over twenty-odd seconds, which is the shape this is meant to look like.
#define RUN_IN_DISTANCE   3000   // m from the aim point back to the run-in start
#define RUN_IN_ALTITUDE   1000   // m above terrain at the run-in start
#define RUN_IN_CAPTURE     150   // m of LATERAL offset from the run-in axis inside which
                                 // the rail may be entered. Lateral, not radial: the
                                 // ingress now crosses the run-in start ALONG the axis
                                 // rather than arriving at it from an arbitrary side.
#define HEADING_TOLERANCE   30   // deg — aligned enough to drop onto the rail. Wider than
                                 // it was because the ingress now delivers the aircraft
                                 // already tracking down the axis, so this is a sanity
                                 // bound rather than the thing doing the work.
#define EGRESS_DISTANCE   4000   // m beyond the aim point
#define EGRESS_CLEAR      1500   // m from the aim point at which the aircraft counts as
                                 // clear of its own bombs and the record can go
#define FLY_HEIGHT_MIN     150   // m — floor for the flyInHeight handed back on egress

// ── Ingress steering ─────────────────────────────────────────────────────────
// This replaces Wargame's precomputed parabolic approach paths entirely. A target
// behind the aircraft produces a reversal because the rotation simply takes
// longer — there is no turnaround case to detect and no path to build.
#define TURN_RATE           12   // deg/s cap. 12 is a 30-second full circle:
                                 // chosen for readable Zeus-scale movement rather
                                 // than for realism. The most likely constant to
                                 // need retuning after in-game test 2.
#define BANK_MAX            60   // deg of roll at full deflection
#define BANK_BAND           45   // deg of YAW ERROR at which the bank saturates. Bank used
                                 // to come from _turn/_maxTurn, which is pinned at ±1 for
                                 // any error above a fraction of a degree — so every turn
                                 // was flown at a hard 60 degrees and snapped level at the
                                 // end. Taken against the error instead, it rolls out.
#define PITCH_RATE          20   // deg/s. Pitch used to be assigned its target outright
#define ROLL_RATE           45   // deg/s. So did roll. Both teleporting is most of what
                                 // reads as robotic — yaw was the only axis ever
                                 // rate-limited, so it was the only one that looked flown.
#define CLIMB_MAX           30   // deg of pitch during ingress, so a run-in start
                                 // far above the aircraft does not stand it on its tail
#define MAX_DELTA          0.5   // s — a frame hitch or a mission-time jump must not
                                 // be handed to the steering as one enormous turn

// How the ingress converges on the run-in AXIS rather than on the run-in POINT. Steering
// at the point delivered an aircraft whose heading was whatever direction it happened to
// arrive from, which the heading gate then rejected — so it sailed past and came round
// again, on a fresh arbitrary heading, until the timeout.
#define INGRESS_LOOKAHEAD  800   // m the carrot leads the aircraft's own projection onto
                                 // the axis. Bigger is a lazier, wider intercept.
#define INGRESS_MIN_FINAL  600   // m behind the run-in start inside which there is no
                                 // approach left to fly and the aircraft must rejoin
#define INGRESS_REJOIN       2   // multiples of RUN_IN_DISTANCE back along the axis for
                                 // the rejoin point
#define INGRESS_REJOIN_SIDE 1200 // m of lateral offset on the rejoin, placed on the side
                                 // the aircraft is ALREADY on so it flies a racetrack
                                 // rather than reversing head-on through the axis
#define FINAL_RANGE        800   // m behind the run-in start at which the carrot stops
                                 // holding run-in altitude and becomes the mark itself, so
                                 // the rate-limited pitch has eased the nose into the dive
                                 // BEFORE the rail takes over

// Cruise is derived from the aircraft's OWN config maxSpeed, not a flat figure:
// a Buzzard and a Caesar BTT have no business flying the same rail. CRUISE_COEF is
// Wargame's ATTACK-RUN fraction (maxSpeedOG * 0.5), not its lower approach one — at
// 0.25 a light propeller aircraft comes out at a walking pace and only the floor
// rescues it, which would make the floor rather than the aircraft decide its speed.
//
// Bounded at BOTH ends, around ZEN's flat CAS_SPEED of 115. Uncapped, a fast jet covers
// the whole rail in seven seconds and the dive is a blur; unfloored at 40, a propeller
// aircraft takes over a minute and runs out of RUN_TIMEOUT partway down.
#define CRUISE_COEF        0.5
#define CRUISE_MIN          70   // m/s floor
#define CRUISE_MAX         130   // m/s ceiling

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
// All four scale with the longer, slower run-in above, and INGRESS_TIMEOUT also has to
// cover a rejoin: an aircraft that arrives level with the run-in start flies a racetrack
// back out to INGRESS_REJOIN before it can try again, and cutting it off mid-racetrack
// would be the same wasted approach the rejoin exists to avoid.
#define INGRESS_TIMEOUT    150
#define RUN_TIMEOUT         60   // the rail is 3162 m; at CRUISE_MIN that is 45 s
#define EGRESS_TIMEOUT      20   // EGRESS_DRIVE comes out of this, then EGRESS_CLEAR
#define STRIKE_TIMEOUT     240
#define CHECK_INTERVAL    0.25   // s — throttle for the abort conditions

// ── Pull-off ─────────────────────────────────────────────────────────────────
// The rail ends with the aircraft pointed into the ground at attack speed. Handing that
// straight to the AI, which is what used to happen, is the jarring part of the run: the
// pilot recovers in his own time and his own way, from an attitude he did not choose.
#define EGRESS_DRIVE       2.5   // s the pull-off stays on the scripted steering
#define EGRESS_LEVEL        10   // deg of remaining nose-down inside which the aircraft
                                 // counts as recovered and the pilot gets it back early

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

// PITCH and BANK are the steering's own state, not readings. FUNC(steerToward) rate-limits
// both, so each tick's output depends on the previous tick's — which is the whole reason
// that function takes the record rather than the aircraft. Neither can be recovered from
// the hull: pitch could be dug back out of vectorDir, but the COMMANDED bank is not the
// bank BIS_fnc_setPitchBank leaves behind once the engine has had its say. Seeded from
// BIS_fnc_getPitchBank at order time so the first tick does not level a banked aircraft in
// one frame, and re-seeded at rail entry so the pull-off starts from the dive it inherits.
#define STRIKE_PITCH     19  // commanded pitch, degrees
#define STRIKE_BANK      20  // commanded bank, degrees
#define STRIKE_EGRESS_AT 21  // time the scripted pull-off gives up; -1 once handed back,
                             // which is what stops the handover re-firing every frame for
                             // the rest of the phase and fighting the pilot it just went to
#define STRIKE_EGRESS    22  // pull-off destination, ASL. Resolved ONCE at rail end rather
                             // than per tick, because it costs a getTerrainHeightASL.
