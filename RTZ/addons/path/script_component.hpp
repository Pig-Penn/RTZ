#define COMPONENT path
#define COMPONENT_BEAUTIFIED Path
#include "\x\rtz\addons\main\script_mod.hpp"

// #define DEBUG_MODE_FULL
// #define DISABLE_COMPILE_CACHE

#ifdef DEBUG_ENABLED_PATH
    #define DEBUG_MODE_FULL
#endif

#ifdef DEBUG_SETTINGS_PATH
    #define DEBUG_SETTINGS DEBUG_SETTINGS_PATH
#endif

#include "\x\rtz\addons\main\script_macros.hpp"

// Path polylines and drag handles draw through rtz_core's ONE Draw3D handler,
// so this component needs that contract (RENDER_WORLD, CTX_*).
#include "\x\rtz\addons\core\script_macros_core.hpp"

// ── What kind of thing is being pathed ───────────────────────────────────────
// Decided ONCE per entity by FUNC(pathKind) and stored in the record, because
// it selects both the drawing rules (does the path need a ground contact test or
// a water test? does it get an altitude stalk?) and, after the network hop, the
// executor. KIND_NONE doubles as the "not pathable" answer, so one call filters
// and classifies in a single pass.
#define KIND_NONE     -1
#define KIND_INFANTRY 0
#define KIND_LAND     1
#define KIND_AIR      2
#define KIND_BOAT     3

// ── Layout of a planned path in GVAR(paths) ────────────────────────────────
// One record per entity being planned, on the CURATOR'S CLIENT only — nothing
// here is authoritative and nothing is broadcast until FUNC(commitPaths) runs.
// An array of records rather than a HashMap: the renderer walks all of them
// every frame, which is the shape an array already is, and the keyed lookups
// (hover, formation offset) are a findIf over at most MAX_PATHS entries. Same
// reasoning, and the same macro-indexed layout, as rtz_slide's GVAR(active).
//
// UNIT is who receives the order — a man on foot, or a vehicle's DRIVER. HULL is
// what actually moves and what the geometry tests measure against; for infantry
// the two are the same object.
//
// POINTS (and HEAD) are ASL positions and nothing else.
//
// ASL, not the AGL Wargame stores: every geometry test that validates a point is
// ASL (lineIntersectsSurfaces, surfaceIsWater, the flight executor), so storing
// AGL means an AGLToASL on every single append — which is what Wargame does, on
// the hottest path it has. Only drawing wants AGL, and drawing is decimated, so
// it touches far fewer points than validation does. ASL is also the only
// unambiguous choice over water, which matters the moment boats are pathable.
//
// One value per point, not four. Wargame carries a tactical-move flag, an
// animation suffix and a facing offset alongside each position. RTZ's executor
// needs the same three things — it is the same puppet — but two of them are
// DERIVED from the third and the third only changes a handful of times in a
// path, so they ride a span list (PATH_FACING) instead of a payload per point.
// The animation name is not carried at all: it depends on the unit's stance,
// weapon and speed mode, none of which the drawing client can know, so it is
// resolved where the unit is local (FUNC(moveAnimation)) and memoised there.
//
// HEAD/DIR are the drag handle's position and facing, cached rather than derived
// from the tail of POINTS so the renderer does not branch on "is this path
// still empty?" for every path, every frame.
//
// LABEL is resolved ONCE, when the session opens. Wargame rebuilds the
// equivalent with `(str _unit) select [2]` inside both of its draw routines,
// which is a str + a select per entity per frame — exactly the per-entity
// per-frame string work CLAUDE.md rules out.
#define PATH_UNIT    0
#define PATH_HULL    1
#define PATH_POINTS  2
#define PATH_COLOR   3
#define PATH_KIND    4
#define PATH_HEAD    5
#define PATH_DIR     6
#define PATH_LABEL   7
// Pre-formatted altitude readout for KIND_AIR, "" for everything else. Built
// where the altitude CHANGES (FUNC(appendPoint)) rather than where it is drawn,
// so the renderer never runs a `str` per handle per frame.
#define PATH_ALT     8
// Outstanding calculatePath search as [expiry, pointCountAtRequest], or [] when
// none is running.
//
// The expiry does two jobs: it stops a second search being started for the same
// path while one is in flight, and it expires on its own so a search the engine
// never answers cannot wedge the path permanently.
//
// The COUNT is the staleness guard. A search takes long enough that the curator
// can drag on past the obstruction and append perfectly good points meanwhile,
// and the answer — a detour computed from a head that has since moved — would
// splice on as a leg jumping backwards to where the path used to be. Wargame
// guards the same window by comparing the head POSITION; a count is the same
// test as an integer compare, and "the path grew" is exactly the condition that
// invalidates the answer.
#define PATH_SEARCH  9
// The unit whose path this one is trailing in formation, or objNull. Set when a
// path starts trailing and cleared the moment the curator grabs that handle
// himself — a path somebody has drawn on by hand is never overwritten.
#define PATH_LEADER  10
// Where along the path the subject faces a fixed direction instead of where it
// is going, as [[fromIndex, azimuth], ...] ascending — a SPAN LIST, not a value
// per point. FACING_NONE ends a span and returns the subject to travel facing.
//
// Wargame carries [isTactical, animationName, facingOffset] alongside EVERY
// point, which is three extra numbers on each of several hundred — and two of
// the three are derivable from the first. Here an entry is pushed only when the
// curator's Alt state or the handle's rotation actually CHANGES, so an ordinary
// path carries an empty list and a heavily-worked one carries a handful of
// pairs. The animation and the steering offset are resolved on the executing
// machine (FUNC(moveAnimation)), which is the only place they are ever read.
//
// The executor reads this list once per leg through a CURSOR carried in the
// follow record (FOLLOW_SPAN), not by rescanning it: leg indices only ever go
// up, so the span in force advances with them and the lookup is an integer
// compare per tick however many spans the curator drew. That is the whole
// performance argument for Wargame's per-point payload, without the payload.
//
// Keeping it out of PATH_POINTS is the other half: that array stays a flat list
// of bare ASL positions, so lineIntersectsSurfaces, distance, vectorFromTo and
// ASLToAGL keep taking its elements directly on every hot path in the component.
#define PATH_FACING  11

// "No fixed facing" — the subject looks where it is going. Used both as a span
// terminator in PATH_FACING and as the resolved answer for a point outside every
// span, so one sentinel covers the whole channel.
#define FACING_NONE -1

// ── How a man executes a path ───────────────────────────────────────────────
// Three positions on one dial rather than two independent switches, because the
// two questions — "may a unit ever be puppeted?" and "is it puppeted for the
// whole path?" — are not independent and a mission that answers the first no and
// the second yes means nothing.
//
//  AI       — the unit's own navigation for every leg. Nothing is ever taken
//             away from it; a marked stretch simply does not happen.
//  SPANS    — its own navigation, puppeted only inside the stretches the curator
//             marked with Alt.
//  SCRIPTED — puppeted end to end, which is Wargame's executor and the only one
//             that walks a drawn line as drawn. The default.
#define EXEC_AI       0
#define EXEC_SPANS    1
#define EXEC_SCRIPTED 2

// ── Layout of a per-kind drawing profile in GVAR(profiles) ──────────────────
// Indexed by KIND_*, built once in XEH_preInit. Wargame recomputes the whole
// equivalent tuple inline on every appended point, on the hottest path it has.
//
// SPACING is the big departure. Wargame samples infantry paths every 0.25 m
// because its executor walks the unit footstep by footstep; RTZ's hands each leg
// to the AI's own navigation, so anything finer than a few metres is detail the
// executor cannot use — and it is what turns a 200 m path from 800 points into
// 70. Everything downstream (the draw, the commit payload, the follow engine)
// is sized by that number.
//
// SMOOTH_STEPS is how far back FUNC(smoothTail) may look for a shortcut, and is
// therefore also the per-point raycast budget for smoothing. Faster-moving kinds
// get more, because their traced corners are wider.
// COMMIT_SPACING is the OTHER sampling rate. A path is drawn dense and
// executed sparse: the fine points exist so the line on screen is the line that
// was traced, but the executor hands each leg to the AI's own navigation, which
// has no use for a target three metres away. FUNC(reducePath) resamples at this
// distance (keeping corners) on the way out, which is what keeps a platoon's
// worth of committed paths from being tens of thousands of numbers on the wire.
#define PROF_SPACING        0
#define PROF_MAX_POINTS     1
#define PROF_MAX_CLIMB      2
#define PROF_MAX_INCLINE    3
#define PROF_CLEAR_HEIGHT   4
#define PROF_LOD_NEAR       5
#define PROF_LOD_FAR        6
#define PROF_SMOOTH_STEPS   7
#define PROF_COMMIT_SPACING 8
// Gap between a path and the one trailing it in formation (meters), converted
// to a count of drawn points by FUNC(formationTrail)
#define PROF_FORMATION_GAP  9
// The commit spacing used when the SCRIPTED executor has the subject — a puppet
// on foot, or an aircraft or boat flown by hand. Much finer than the one above,
// and for the same reason it is coarser there: a doMove chain hands each leg to
// the AI's own navigation and a target three metres ahead is useless to it,
// whereas a scripted executor walks or flies the polyline literally and every
// point it is not given is a corner it cuts.
//
// This is the real content of Wargame's "one point every 0.25 m". The number
// matters, the storage does not: FUNC(reducePath) still drops the points that
// sit on a straight run and still keeps every corner, so a scripted infantry
// path leaves here at a few dozen legs rather than the eight hundred Wargame
// would send for the same 200 m.
#define PROF_SCRIPTED_SPACING 10

// ── Aircraft altitude drag ──────────────────────────────────────────────────
// An aircraft path is drawn in two gestures: dragging the handle moves it
// horizontally at the altitude it already has, and dragging with a modifier held
// moves it vertically instead. Alt is the fine control, Shift the coarse one.
//
// The rates are metres per full sweep of the screen: screen coordinates run
// 0..1, so dragging from the bottom of the screen to the top changes altitude by
// this much.
#define ALT_RATE      250
#define ALT_RATE_FAST 1000

// Floor a drawn flight path is held above the terrain (meters). A path traced
// along the ground is almost never what was meant, and a helicopter ordered into
// the dirt simply refuses.
#define AIR_MIN_ALT 15

// Spacing used instead of the profile's when a sample is mostly VERTICAL. The
// 25 m spacing an aircraft path is traced at is right for flying across a map
// and absurd for setting a height — it would take a 25 m climb before the first
// point registered.
#define AIR_CLIMB_SPACING 6

// A sample counts as a climb rather than a traverse when this much of its length
// is vertical
#define AIR_CLIMB_RATIO 0.7

// ── Aircraft echelon ────────────────────────────────────────────────────────
// A flight given ONE traced line would otherwise fly it at one altitude in one
// file, which is not a formation — it is several aircraft converging on the same
// piece of air at different speeds. So each rank trailing the leader is lifted
// and stepped out to the side of the line of travel, alternating left and right
// by rank, which is what Wargame does and the reason its flights arrive intact.
//
// Metres of separation per rank. The lateral step is the larger of the two
// because rotor discs are wide and altitude alone still puts a following
// aircraft in the leader's downwash.
#define AIR_STACK_ALT   24
#define AIR_ECHELON_SIDE 30

// ── Road magnetisation ──────────────────────────────────────────────────────
// Holding the modifier while tracing a vehicle path pulls each sample onto the
// nearest road, which is what makes a convoy path drawable at all — freehand
// tracing of a winding road produces a line that clips every verge.
//
// The search is biased FORWARD along the direction of travel by this fraction of
// the current sample, so it does not keep finding the piece of road already
// under the handle and refusing to advance.
#define ROAD_SNAP_BIAS 0.7
#define ROAD_SNAP_RADIUS 60
// Beyond this the cursor is nowhere near the road being followed and snapping
// would teleport the path (meters)
#define ROAD_SNAP_MAX 400
// Roads sit fractionally below their own surface; this lifts a snapped point
// clear so the line test does not immediately hit the road itself (meters)
#define ROAD_LIFT 0.5

// ── Line-of-sight auto-pathing ──────────────────────────────────────────────
// When a traced sample is blocked, the engine's own pathfinder is asked for a
// way through and the answer is spliced in — so a curator can drag straight at a
// compound and have the path go round it, or through its doors, without
// hand-tracing every corner.
//
// BOUNDED. A search that the engine never answers must not wedge the path or
// leak its agent, so the same timeout retires both (seconds).
#define AUTOPATH_TIMEOUT 6

// Longest single segment a cursor sample may add (meters). A cursor swept across
// a ridge line resolves onto a hillside hundreds of metres away in one frame;
// without this the path grows a straight leg through everything in between,
// validated only by a line test that is nowhere near what was traced.
#define MAX_SEGMENT 250

// Ground contact is normally free: the cursor position already comes off a
// surface (zen_common_fnc_getPosFromScreen is asked for intersections), and the
// incline gate rejects cliff faces. Wargame fires EIGHT downward rays per point
// regardless. The one case that still needs a ray here is a point over
// WATER, where a land path is either crossing a bridge or is invalid — this is
// how far above and below the point that ray looks (meters).
#define BRIDGE_PROBE 3

// ── Layout of a path being followed, in GVAR(active) ───────────────────────
// One record per unit currently executing a path ON THIS MACHINE — the one the
// unit is local to, which is the only machine an AI order does anything on.
// Written by FUNC(startFollow), driven by FUNC(followTick), torn down by
// FUNC(endFollow). Structurally the same idea as rtz_slide's maneuver record,
// but NOT indexed the same way in practice: rtz_slide reads its record through
// the MANEUVER_* macros, whereas FUNC(followTick) destructures this one with
// `params` in one go and only writes back through INDEX, MOVED_AT and CHECK_AT.
// The remaining names below document the layout that `params` line depends on —
// if you reorder one, reorder the other.
//
// UNIT is load-bearing for the same reason it is there: teardown hands back the
// unit this record actually stopped, not whoever is in the seat when it ends.
// DRIVE is the [x, y, 0, speed] form setDriveOnPath wants, built once for land
// vehicles and empty for everything else, so a patrol lap can re-issue it
// without rebuilding.
// ARRIVAL is resolved per record rather than per kind, because a plane and a
// helicopter are both KIND_AIR and are nothing alike about it.
#define FOLLOW_UNIT     0
#define FOLLOW_HULL     1
#define FOLLOW_POINTS   2
#define FOLLOW_INDEX    3
#define FOLLOW_KIND     4
#define FOLLOW_PATROL   5
#define FOLLOW_END_TIME 6
#define FOLLOW_MOVED_AT 7
#define FOLLOW_CHECK_AT 8
#define FOLLOW_DRIVE    9
#define FOLLOW_ARRIVAL  10
// The facing spans the curator drew (layout as PATH_FACING, remapped onto these
// legs by FUNC(commitPaths)), and the state of the tactical executor driving
// them: the animation currently looping, and the AnimDone handler looping it.
//
// ANIM is "" and ANIM_EH is -1 whenever the unit is NOT inside a span, which is
// also the "nothing to restore" test FUNC(endFollow) reads. Both are carried in
// the RECORD rather than on the unit, so teardown does not depend on an event
// having fired or on a variable surviving a machine change: the record is what
// the tick already holds, and it is what ends the path.
#define FOLLOW_FACING   11
#define FOLLOW_ANIM     12
#define FOLLOW_ANIM_EH  13
// Hit handler feeding the combat pause, -1 when none is installed. Lives
// alongside FOLLOW_ANIM_EH and is created and destroyed with it.
#define FOLLOW_HIT_EH   14
// Earliest time the engine's driving path may be re-asserted (see
// DRIVE_RETRY_TIME). A clock of its own rather than a reuse of MOVED_AT: that
// one is the stuck timer, and resetting it on every retry would mean a vehicle
// that can never start is re-issued forever instead of being abandoned at
// STUCK_TIME. KIND_LAND only, 0 for everything else.
#define FOLLOW_RETRY_AT 15
// When the record's FIRST order may be issued, or 0 once it has been.
//
// The launch is deferred rather than issued by FUNC(startFollow) for two
// reasons. It is the only way to give a RE-TASKED unit the settle Wargame
// insists on — it waits 0.2 s between ending one scripted move and starting the
// next, and warns that ordering a unit straight after tearing down its previous
// order "causes weird behaviour" — without a spawn or a waitAndExecute per
// order. And it puts the whole launch on the tick, which is the only place that
// has already re-checked that the unit is alive, local and still in its seat.
#define FOLLOW_START_AT 16
// Cursor into FOLLOW_FACING: the index of the last span whose start the current
// leg has passed, or -1 while the path is still before the first one. Leg
// indices only ever go up, so this only ever goes up with them.
#define FOLLOW_SPAN     17
// The subject is on the SCRIPTED executor rather than on its own navigation —
// a puppet on foot, or a hand-flown aircraft or boat. Read from the setting
// once, where the unit is local, so a mid-path settings change cannot leave
// half a route on one executor and half on the other.
#define FOLLOW_SCRIPTED 18
// Who the puppet broke off to engage (objNull when it is walking), and the
// latest time it may still be doing so. The deadline is the difference between
// this and Wargame's: there, a unit that gets stuck in an engagement it cannot
// resolve never resumes its path and no clock exists that would notice.
//
// FOLLOW_ENGAGE_AT carries two clocks, told apart by FOLLOW_TARGET: a deadline
// while a target is held, and the earliest the unit may break off again while
// none is. They can never be live at the same time.
#define FOLLOW_TARGET   19
#define FOLLOW_ENGAGE_AT 20
// Scripted flight: speed the hull is being moved at right now (m/s) and the
// cruise it is accelerating toward before turn scaling takes a bite out of it.
#define FOLLOW_SPEED    21
#define FOLLOW_CRUISE   22
// Scripted flight profile as [isHeli, isPlane, isNaval, pitch, turnCoef], or []
// for anything not being flown by hand. Resolved once per record because every
// term is a config or class question about a hull that cannot change under it.
#define FOLLOW_FLIGHT   23
// Hull position at the previous movement step, for the passed-the-waypoint test
// a fast aircraft needs — at 90 m/s a leg can be entered and left inside one
// tick and a pure distance test never sees it.
#define FOLLOW_LAST_POS 24
// The first order has gone out (FUNC(launchFollow)). A flag of its own rather
// than a zeroed FOLLOW_START_AT, because that field is still wanted afterwards:
// it is the clock a scripted flight measures its liftoff grace from.
#define FOLLOW_LAUNCHED 25

// How often the shared handler wakes (seconds), and how often each record's
// CONDITION checks — alive, local, still in the seat, stuck, arrived — run once
// it does.
//
// Two cadences, because there are two kinds of work. Steering a puppet and
// flying a hull by hand are movement and happen on every wake; deciding whether
// a path should still be running is a question that changes on human timescales
// and rides the half-second stagger, which also spreads it so paths are examined
// a few at a time rather than all on the same tick. A land vehicle is driven by
// the engine and has no movement half at all, so it only ever costs the stagger.
//
// Ten times a second is the whole budget for the scripted executors, and it is
// enough because neither of them integrates anything: setVelocity persists until
// something changes it, and an animation carries a man along on its own between
// steering corrections. Wargame's equivalent runs a handler at 0.001 PER UNIT,
// alongside a second at 0.1 and a third at 0.5, and a fourth at 0.0005 for
// anything that flies — and then throttles the flight one to every tenth wake,
// arriving at roughly this cadence by a much more expensive route.
#define TICK_INTERVAL 0.1
#define CHECK_INTERVAL 0.5

// Settle between tearing down a unit's previous path and launching its next
// (seconds). Wargame waits 0.2 s here and warns that ordering a unit
// immediately after ending its scripted move "causes weird behaviour"; on foot
// it waits 0.25 s. One number covers both.
#define RETASK_SETTLE 0.25

// How close a unit must get to a leg's end for it to count as reached (meters).
// Below the drawn spacing of its kind, or a unit would satisfy several legs at
// once — which is handled anyway (see MAX_SKIP), but as a corner case rather
// than as the normal path.
//
// A plane's is enormous because a plane cannot stop, hover or turn tightly: it
// has reached a waypoint when it is in the neighbourhood, and insisting on more
// makes it circle the point forever instead of flying on to the next.
#define ARRIVAL_INFANTRY 5
#define ARRIVAL_LAND 15
#define ARRIVAL_BOAT 25
#define ARRIVAL_HELI 40
#define ARRIVAL_PLANE 200

// The same thing for the SCRIPTED executors, and much tighter, because the two
// radii answer different questions. On a doMove chain the radius has to be
// generous enough that the AI's own idea of where the leg ended still counts as
// arriving; on a scripted executor the hull is being placed, so it always
// arrives exactly and the radius is nothing but the width of the tube the path
// is tracked within. Wargame's are 1 m on foot and 12 for a helicopter, against
// its 65 for a plane — which cannot be tracked tightly whatever moves it,
// because the model has to bank through a corner it is already committed to.
#define ARRIVAL_PUPPET 2.5
#define ARRIVAL_FLIGHT_HELI 15
#define ARRIVAL_FLIGHT_PLANE 65
#define ARRIVAL_FLIGHT_BOAT 12

// ── setDriveOnPath fail-safe ────────────────────────────────────────────────
// The engine's driving path is FRAGILE. Any other order reaching the driver
// clears it — a group leader re-forming, a danger FSM reaction, a LAMBS tactic,
// a JIP settling — and the vehicle simply stops. Nothing reports that: the only
// evidence is a vehicle sitting still on a path it never started, which the
// stuck clock then takes a full STUCK_TIME to notice and then abandons.
//
// So it is re-issued, but ONLY while the vehicle has not left its start point.
// setDriveOnPath restarts from the head of the array it is given, so
// re-asserting after the vehicle had made ground would drive it back to where it
// set off — worse than the stall. Wargame's fail-safe is bounded the same way,
// at the same 5 m, for the same reason.
//
// Seconds stationary before the path is re-asserted, and how far from the first
// leg it may have got and still be a candidate (meters).
#define DRIVE_RETRY_TIME 10
#define DRIVE_RETRY_DIST 5

// Legs a unit may be credited with in one tick. A tight corner drawn at 3 m
// spacing puts several points inside the arrival radius at once, and walking
// past them one tick at a time would stall the unit on the inside of the turn.
#define MAX_SKIP 8

// How far the AI's own plan may drift from this path's current leg before the
// order is re-asserted (meters). This is the whole reason a doMove chain
// survives the formation FSM: a subordinate is dragged back into formation
// within seconds of being given an order, and re-issuing doMove unconditionally
// makes the AI re-plan every tick and visibly stutter. Comparing against
// expectedDestination re-asserts exactly when the order was actually stolen and
// never otherwise — the trick LAMBS uses in lambs_main_fnc_doAssault.
#define REPLAN_TOLERANCE 3

// ── Scripted infantry move ──────────────────────────────────────────────────
// A man on a scripted path is a PUPPET: MOVE and ANIM are disabled, he is
// carried by a directional movement animation, and his hull is turned by hand
// each tick toward the leg. This is Wargame's executor and it is the reason a
// drawn infantry path is walked as drawn — a doMove chain hands each leg to the
// AI, which rounds the corners, forms up, and generally arrives somewhere near
// the line rather than on it.
//
// What Wargame pays for that is a unit that cannot react to anything, and the
// answer to that is not to give up the executor — it is to give the puppet the
// two reactions that matter. It breaks off to engage what shoots at it or what
// walks into its arc (COMBAT_* below, FUNC(combatPause)) and resumes afterwards,
// and it opens the doors in front of it (DOOR_* below, FUNC(openDoors)). It
// still cannot take cover or path around an obstacle it was walked into, which
// is what the curator drawing the line is for.
//
// A facing span (the curator holds Alt) changes which of the eight directional
// animations the puppet is walking on, and nothing else — the executor is the
// same one either way.
//
// Turn per tick, in degrees: the coarse step while the hull is still swinging
// onto the leg, the fine one once it is nearly there. A single step size either
// snaps the model round or never converges; Wargame's two-speed swing is what
// makes it read as a soldier turning.
//
// Sized for TICK_INTERVAL, NOT copied from Wargame's numbers. Wargame's handler
// runs at 0.001 — per frame in practice — so its 9-degree coarse step is 540
// degrees a second and the model snaps round. The same step on a 0.1 s tick
// would be 90 a second, which is too slow to hold a line. These give roughly
// 180 and 30 degrees a second, which is a soldier turning briskly and then
// settling.
//
// FINE must stay below ALIGNED or the fine step oscillates about the heading it
// is converging on instead of reaching it.
#define TACTICAL_TURN_COARSE 18
#define TACTICAL_TURN_FINE   3
// Within this many degrees of the leg, use the fine step
#define TACTICAL_TURN_ALIGNED 18

// Most distinct animation names FUNC(moveAnimation) will remember. The key space
// is stance x weapon x pace x direction, so a couple of hundred covers every man
// in a mission several times over — the bound exists because a HashMap that only
// ever grows is a leak on a multi-hour operation, not because this one is
// expected to fill.
#define ANIM_CACHE_MAX 256

// ── Puppet combat reaction ──────────────────────────────────────────────────
// A puppet that walks through a firefight without reacting is the single worst
// thing about Wargame's executor, and it is not inherent to it: Wargame itself
// pauses the scripted move to engage and resumes after. That is ported, on this
// component's own terms — no per-unit handler, a bounded engagement, and the
// path's own stuck clock held off for as long as the pause lasts.
//
// How far a threat may be and still be worth stopping for, by what is in the
// unit's hands. A man with a launcher or nothing has no business breaking off
// for anything he is not standing on top of, which is Wargame's reasoning and
// very nearly its numbers.
#define ENGAGE_RANGE_RIFLE 90
#define ENGAGE_RANGE_PISTOL 50
#define ENGAGE_RANGE_NONE 5

// A hit from further away than the corresponding range still turns the head —
// the instigator is remembered and engaged if it closes — but this is the
// ceiling past which being shot at is somebody else's problem (meters).
#define ENGAGE_HIT_RANGE 250

// Longest a single engagement may hold the path (seconds). Wargame's has no
// bound at all, so a unit that cannot resolve its target — one it can see but
// not kill, one behind glass — simply never finishes its route.
#define ENGAGE_MAX_TIME 45

// Time after an engagement ends before the same unit may break off again
// (seconds). Without it a target that keeps flickering in and out of line of
// sight stops and starts the puppet several times a second.
#define ENGAGE_COOLDOWN 5

// ── Puppet door handling ────────────────────────────────────────────────────
// A puppet cannot open a door — it has no AI movement left to do it with — so a
// path drawn through a building ends against the first closed one. The sweep
// runs on the record's half-second stagger, and only for a unit close enough to
// a building to be walking into it.
//
// How near a building has to be before its doors are looked at, and how near a
// door has to be before it is opened (meters).
#define DOOR_BUILDING_DIST 12
#define DOOR_REACH 2.5

// Most building classes whose door selections are remembered. Wargame runs
// `selectionNames` over the nearest building every half second per unit; the
// answer is a property of the CLASS, so it is asked once per class instead.
#define DOOR_CACHE_MAX 128

// ── Scripted flight and sailing ─────────────────────────────────────────────
// setDriveOnPath has no effect on Air or Ship — it needs an AI steering
// component neither has — so an aircraft or boat given a doMove chain flies the
// legs it feels like, at the speed it feels like, and cuts every corner. Wargame
// writes its own flight model for exactly that reason and it is the right call;
// what is wrong with it is the cadence (a 0.0005 s handler per aircraft, then
// throttled internally to every tenth wake) and the unbounded waits around it.
//
// Here the same model rides the shared tick. setVelocity persists until
// something changes it, so ten steps a second is not an approximation of the
// per-frame version — it is the same trajectory sampled less often.
//
// Nose attitude, in degrees, rotated about the hull's own lateral axis so the
// model leans into its travel instead of flying dead level. Wargame's figures:
// a helicopter noses down, a boat sits back on its stern, a plane needs neither
// because its nose already follows the full 3D direction of travel.
#define FLIGHT_PITCH_HELI  20
#define FLIGHT_PITCH_BOAT  -5
#define FLIGHT_PITCH_PLANE 0

// How hard each domain slows for a bend. A plane has to lose real speed to hold
// a turn radius that keeps it on the line; a helicopter can nearly ignore it.
#define FLIGHT_TURN_HELI  1.25
#define FLIGHT_TURN_PLANE 2
#define FLIGHT_TURN_BOAT  1.5

// Legs ahead the turn scaling looks, and the bend (degrees) at which it is
// applied in full. Beyond that the scaling is already saturated and a sharper
// corner cannot slow the hull further.
#define FLIGHT_LOOKAHEAD 6
#define FLIGHT_TURN_FULL 45

// Never slow below this fraction of cruise, however sharp the path — a hull that
// scales itself to a standstill never reaches the corner it was slowing for.
#define FLIGHT_SPEED_FLOOR 0.2

// Speed change per tick as a fraction of cruise. Deceleration is the larger of
// the two on purpose: arriving at a corner too fast is a hull that overshoots
// the line, arriving too slow is a hull that catches up on the next straight.
#define FLIGHT_ACCEL 0.008
#define FLIGHT_DECEL 0.04

// Final approach for a helicopter on a one-way path: over the last few legs it
// comes down to this fraction of cruise and tightens what counts as arrived, so
// it settles onto the last point rather than flying through it and coming back.
#define FLIGHT_FLARE_LEGS 4
#define FLIGHT_FLARE_COEF 0.25
#define FLIGHT_FLARE_ARRIVAL 8

// A path whose last point sits this close to the ground was drawn as a landing
// (meters), so the helicopter is told to land there rather than left hovering
// at a height nobody asked for.
#define FLIGHT_LAND_ALT 6

// Longest an aircraft may be given to get off the ground before the scripted
// model takes over anyway (seconds). Wargame waits on an unbounded `waitUntil`
// here, which never returns for an aircraft that cannot lift — a damaged rotor,
// a hangar roof — and leaks its thread. Taking over regardless is also the
// better failure: the first leg is above the aircraft, so the velocity the model
// applies lifts it.
#define FLIGHT_LIFTOFF_TIME 8

// Below this the hull is treated as pointing wherever it already points rather
// than along its travel, because a direction of travel this close to vertical
// has no heading to derive an attitude from.
#define FLIGHT_HEADING_MIN 0.05

// Speed below which a unit counts as not moving (km/h) and how long it may stay
// that slow before its path is abandoned as stuck (seconds). STUCK_TIME is
// deliberately long: a unit that stops for twenty seconds is usually taking
// cover or returning fire, and cancelling a path for that would punish exactly
// the behaviour the doMove executor was chosen to preserve.
#define STUCK_SPEED 0.5
#define STUCK_TIME 60

// ── Speed of a followed path ────────────────────────────────────────────────
// Land vehicles get their speed per point through setDriveOnPath. Aircraft and
// boats get theirs as the cruise the scripted model accelerates toward — and,
// when the scripted executor is switched off and they fall back to a doMove
// chain, as a limitSpeed ceiling, because a doMove chain carries no speed at all
// and an aircraft given one flies a carefully traced approach at whatever the AI
// feels like and overshoots every leg it was given.
//
// Fractions of the hull's config maxSpeed, matching Wargame's per-domain
// multipliers, with a ceiling for the aircraft whose config figure is a dive
// speed rather than a cruise. Under limitSpeed the AI still slows for terrain,
// landing and traffic instead of being held to a number.
#define SPEED_HELI_COEF  0.2
#define SPEED_PLANE_COEF 0.25
#define SPEED_BOAT_COEF  0.2
#define SPEED_CAP 125
// Handed back to limitSpeed when the path ends. The engine has no "remove the
// limit" value, so the convention is a number no vehicle can reach — without it
// a helicopter given one traced approach stays capped at approach speed for the
// rest of the mission. FUNC(endFollow) owns this, and it is the reason the
// ceiling below is safe to apply at all.
#define SPEED_UNLIMITED 1e10
// Applied on top when the group is not on NORMAL speed mode. Land uses its own
// halving (FUNC(startFollow)); this is the figure Wargame uses off the ground.
#define SPEED_LIMITED_COEF 0.4

// ── Planning tint ───────────────────────────────────────────────────────────
// Post-process layer for the desaturation applied while a session is open.
//
// Deliberately NOT Wargame's 1501. Wargame is loaded alongside RTZ in the
// missions this is built for, and two mods creating an effect on one layer means
// whichever destroys last wins while the other's handle is left pointing at
// nothing — a tint that can never be removed for the rest of the mission. The
// number is arbitrary and only has to be unique; it sits well clear of the
// 100–5000 band ACE, ZEN, CBA and Wargame all occupy.
#define PP_LAYER 663201

// Wargame's own colorCorrections values, which are a straight luminance-weighted
// desaturation at 85% brightness: enough that the mode is unmistakable, little
// enough that path colours still read.
#define PP_BRIGHTNESS 0.85
#define PP_CONTRAST   1.0
#define PP_OFFSET     0
#define PP_LUMA_WEIGHTS [0.299, 0.587, 0.114, 0]

// How long the modifier hint stays up when a session opens (seconds)
#define HINT_TIME 8

// Corner detection for FUNC(reducePath): a heading change of at least this many
// degrees is a corner and survives resampling however close it is to the last
// kept point.
#define COMMIT_ANGLE 25

// A path whose ends meet is a patrol: it commits as a loop instead of a
// one-way move. Needs a minimum length as well as closed ends, or every short
// there-and-back scribble becomes an endless circuit.
#define PATROL_MIN_POINTS 12
#define PATROL_CLOSE_DIST 25

// Most entities that may be planned at once. A curator who selects half the map
// and hits the key gets the first MAX_PATHS of them rather than a client that
// stalls building handles for four hundred units. Wargame has no cap at all and
// will happily seed a handle for every editable object on the mission when its
// "only for controlled units" setting is off.
#define MAX_PATHS 48

// ── Drawing ─────────────────────────────────────────────────────────────────
// Shared by the 3D renderer and the Zeus-map one so the two cannot drift apart.
// Wargame's equivalents are duplicated verbatim between its two draw routines,
// including a three-tier decimation table repeated line for line.
// All three are textures already in production use elsewhere (ZEN's dialog
// slider draws dot_ca, Wargame's own path renderer uses arrow2_ca and join_ca),
// which is the only cheap way to be sure a path resolves — a drawIcon3D against
// a texture that does not exist fails silently and simply draws nothing.
#define ICON_HANDLE "\a3\ui_f\data\map\markers\military\arrow2_ca.paa"
#define ICON_POINT  "\a3\ui_f\data\map\markers\military\dot_ca.paa"
#define ICON_CUT    "\a3\ui_f\data\map\markers\military\join_ca.paa"
#define PATH_FONT  "RobotoCondensed"

// The path's start is the same dot as every other point, drawn larger, rather
// than a marker of its own
#define ORIGIN_SIZE_SCALE 1.8

// World-space lift so the handle floats clear of the model it belongs to, and a
// smaller one that keeps the path line off the ground it follows (meters).
#define HANDLE_LIFT 2.2
#define LINE_LIFT   0.5

#define HANDLE_SIZE       1.6
#define HANDLE_SIZE_HOVER 2.2
#define POINT_SIZE        0.7
#define LINE_WIDTH        6
#define TEXT_SIZE         0.03

// Squared screen-space pick radii. Screen coordinates run 0..1, so these are
// radii of 0.05 and 0.03 — the same scale rtz_spotting picks its icons at.
// The handle is the mode's primary target and is deliberately the more generous
// of the two.
#define HANDLE_HIT_R2 (0.05 * 0.05)
#define POINT_HIT_R2  (0.03 * 0.03)

// Alpha for a path that is neither hovered nor being dragged, and for one that
// is. Wargame achieves the same emphasis by rewriting a local object's texture
// with a formatted colour string, per handle, per frame.
#define ALPHA_IDLE   0.55
#define ALPHA_ACTIVE 1

// Line segments a single path may draw per frame, before distance reduces it.
// A path at DRAW_NEAR metres or closer gets the full budget; further out the
// budget falls off with distance to DRAW_MIN, because a path two kilometres
// away is a few pixels of line however many segments it is made of.
//
// This replaces Wargame's decimation, which switches stride at 225, 3000 and
// 6000 points via four interacting index variables — duplicated, unchanged,
// in both of its draw routines.
#define DRAW_BUDGET 80
#define DRAW_NEAR   300
#define DRAW_MIN    12

// One waypoint dot every this many drawn segments. Dots mark the line as a plan
// rather than a decoration; one per point is noise at any sampling rate.
#define DOT_EVERY 5

// Beyond this the label under a handle is unreadable anyway (meters)
#define LABEL_MAX_DIST 900

// Zeus map: icon size in pixels, and the pick radius as a multiple of the map's
// current scale so it stays a constant distance ON SCREEN at any zoom.
#define MAP_ICON_SIZE 22
#define MAP_POINT_SIZE 10
#define MAP_LINE_WIDTH 5
#define MAP_HIT_SCALE 360

// Colour of the cut marker drawn on the path point the cursor would remove
#define COLOR_CUT [0.95, 0.15, 0.15, 0.9]

// How often FUNC(planTick) re-checks that its subjects are still pathable
// (seconds). Only the cursor sample runs every frame; a unit being killed,
// deleted or driven off changes on human timescales and does not need sixty
// looks a second.
#define PRUNE_INTERVAL 0.5

// Keys the planning mode consumes, as DIK codes. The modifiers are NOT here:
// KeyDown/KeyUp/MouseButtonDown all carry _shift/_ctrl/_alt as parameters, so
// modifier state is read from the events this mode already registers and dies
// with the mode — rather than living in the mission-wide globals Wargame keeps
// (jac_holdLAlt, jac_leftCtrlKeyPressed, jac_draw_ruler).
#define DIK_ESCAPE 0x01
#define DIK_DELETE 0xD3
