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
// reasoning, and the same macro-indexed layout, as rtz_reverse's GVAR(active).
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
// animation suffix and a facing offset alongside each position because its
// executor forces animations; RTZ's does not, so three quarters of that payload
// would be dead weight on an array that grows into the thousands.
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
// Expiry stamp of an outstanding calculatePath search, 0 when none is running.
// One stamp does both jobs: it stops a second search being started for the same
// path while one is in flight, and it expires on its own so a search the engine
// never answers cannot wedge the path permanently.
#define PATH_SEARCH  9
// The unit whose path this one is trailing in formation, or objNull. Set when a
// path starts trailing and cleared the moment the curator grabs that handle
// himself — a path somebody has drawn on by hand is never overwritten.
#define PATH_LEADER  10

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
// FUNC(endFollow). Structurally the same idea as rtz_reverse's maneuver record,
// but NOT indexed the same way in practice: rtz_reverse reads its record through
// all seven MANEUVER_* macros, whereas FUNC(followTick) destructures this one with
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

// How often the shared handler wakes (seconds), and how often each record is
// actually examined once it does.
//
// NOTHING here needs the frame rate. Advancing a leg, noticing an arrival and
// every abort condition change on human timescales, and no executor pushes an
// object around by hand — the engine drives land vehicles and the AI flies,
// sails and walks the rest. So the handler wakes ten times a second and each
// record rides its own half-second stagger inside that, which spreads the work
// instead of examining every path on the same tick.
//
// Wargame's equivalent runs a handler at 0.001 PER UNIT, alongside a second at
// 0.1 and a third at 0.5, and a fourth at 0.0005 for anything that flies.
#define TICK_INTERVAL 0.1
#define CHECK_INTERVAL 0.5

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

// Speed below which a unit counts as not moving (km/h) and how long it may stay
// that slow before its path is abandoned as stuck (seconds). STUCK_TIME is
// deliberately long: a unit that stops for twenty seconds is usually taking
// cover or returning fire, and cancelling a path for that would punish exactly
// the behaviour the doMove executor was chosen to preserve.
#define STUCK_SPEED 0.5
#define STUCK_TIME 60

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
