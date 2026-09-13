#define COMPONENT dig
#define COMPONENT_BEAUTIFIED Dig
#include "\x\rtz\addons\main\script_mod.hpp"

// #define DEBUG_MODE_FULL
// #define DISABLE_COMPILE_CACHE

#ifdef DEBUG_ENABLED_DIG
    #define DEBUG_MODE_FULL
#endif

#ifdef DEBUG_SETTINGS_DIG
    #define DEBUG_SETTINGS DEBUG_SETTINGS_DIG
#endif

#include "\x\rtz\addons\main\script_macros.hpp"

// The aim session draws its cell markers through rtz_core's ONE Draw3D handler,
// so this component needs that contract (RENDER_WORLD, CTX_*).
#include "\x\rtz\addons\core\script_macros_core.hpp"

// ── Trench geometry ──────────────────────────────────────────────────────────
// The trench IS the heightmap. Nothing is modelled — no floor, no walls — so there is
// no model geometry to take measurements from any more, and DEPTH is the single lever
// the whole feature has. That is why it is a setting (GVAR(depth)) rather than a
// number here: with the blocks gone it stopped being a fact about a model and became
// the one thing worth tuning in game.
//
// Zeus Wargame's "dig in" (jac_fnc_digInWPStatement) is the reference, and this already
// matched its terrain maths exactly while the blocks were still here: 1.7 m, one
// heightmap vertex per cell, grid-snapped, adjustObjects false, server-side.
#define CLUTTER_CUTTER "Land_ClutterCutter_large_F"

// s the cutter lives for after its cell finishes — Wargame's figure. Grass grows back
// afterwards, which is the trade for not leaving one object per cell standing in the
// world for the rest of a multi-hour operation.
#define CUTTER_LIFETIME 300

// ── Terrain grid limits ──────────────────────────────────────────────────────
// setTerrainHeight moves heightmap VERTICES, so the smallest feature expressible is
// one cell — and since the deformation is now the entire trench, the grid decides what
// the feature can look like rather than merely how it is assembled.
//
// Above CELL_MAX one dropped vertex spreads over a cone wider than the trench is long
// and reads as a crater: Altis is 7.5 m, and ACE names Malden's 12.5 m as a map that
// legitimately cannot be dug. CELL_MIN is the far weaker bound of the two now — a fine
// grid is an ASSET here, giving a sharper cut than Altis can express, and the floor
// only exists because a sub-metre grid turns a 1.7 m drop into a spike.
#define CELL_MIN      1
#define CELL_MAX     10

// m ASL a dug vertex may never be taken below. A cell a metre above the waterline dug
// to full depth would otherwise flood, which is a worse outcome than a shallow trench.
// Wargame guards the same case with its own `_newHeight > 0` test.
#define MIN_HEIGHT    0.1
#define MIN_CELLS     2     // a one-cell trench has no interior vertex. That used to
                            // mean "places blocks and deforms nothing"; now it means
                            // it would do nothing whatsoever

// ── Aim session ──────────────────────────────────────────────────────────────
#define PLAN_INTERVAL 0.15  // s between re-plans while the curator drags. FUNC(planTrench)
                            // walks every cell with nearestObjects/nearestTerrainObjects,
                            // which is far too expensive for a MouseMoving handler — the
                            // cursor is latched there and the walk happens here, the way
                            // rtz_airstrike caches its validity check on AIM_VALID_INTERVAL.
#define MARKER_SIZE   1.2   // m — drawn cell marker
#define HINT_TEXT_SIZE 0.03

#define ICON_DIG      "\a3\ui_f\data\igui\cfg\simpleTasks\types\defend_ca.paa"
#define COLOR_DIG     [0.55, 0.75, 0.35, 1]
#define COLOR_INVALID [0.9, 0.2, 0.2, 1]

// ── Digging ──────────────────────────────────────────────────────────────────
#define DIG_DISTANCE   3    // m — arrival radius for the walk to a cell
#define DIG_ANIM_PERIOD 3   // s — MedicOther runs about this long, so it is re-played on
                            // this period rather than once. Wargame drives its
                            // fortification animation the same way.

// ── Layout of a session in GVAR(aiming) ──────────────────────────────────────
// Client-local, exactly one at a time. Index 4 is a FRAME guard, not a flag: this
// session is opened by CLICKING a context-menu entry, and whether that same click
// also reaches the display handler installed below is engine-ordering dependent.
// See rtz_airstrike's FUNC(beginAiming) for the full argument.
#define AIM_OBJECTS  0
#define AIM_START    1   // ASL, [] until the curator presses
#define AIM_END      2   // ASL, the live cursor point
#define AIM_PLAN     3   // last FUNC(planTrench) result, refreshed on PLAN_INTERVAL
#define AIM_HANDLERS 4
#define AIM_FRAME    5
#define AIM_PLANAT   6   // next re-plan time

// ── Layout of a cell in a plan ───────────────────────────────────────────────
// One cell is one unit of work: one engineer walks to CELL_CENTRE and digs, and the
// server sinks THIS cell's vertex as he does it.
//
// CELL_VERTEX carries the PRISTINE height, resolved once at plan time, and every sink
// is computed as an absolute height from it — original - fraction * depth — never by
// subtracting from whatever the heightmap says at the time. Cells share vertices with
// their neighbours and a sink now arrives ~15 times per cell rather than once, so a
// reader of the live heightmap would give a different answer depending on which
// neighbour ticked last, and a single dropped event would be permanently wrong.
// See docs/Knowledge Base/Gotchas.md.
#define CELL_CENTRE  0   // [x,y] — where the engineer is sent, and the preview marker
#define CELL_VERTEX  1   // [x, y, originalHeight], or [] for the two end cells, which
                         // deform nothing: dropping the outer vertices would pull the
                         // trench floor up out of the surrounding ground (ACE skips
                         // them too)
#define CELL_SUNK    2   // how far down this cell has been taken, 0..1 of GVAR(depth).
                         // SERVER-side, and monotonic: it is what makes a late or
                         // duplicated progress event unable to raise the ground back up

// ── Layout of a trench record in GVAR(trenches) ──────────────────────────────
// Server-only, bounded by GVAR(maxTrenches). Holds what a future fill-in order would
// need — the ORIGINAL vertex heights — so that order can be added without retrofitting
// the data model. Nothing is created that outlives the dig any more, so there is no
// list of objects to keep alongside them.
#define TRENCH_ID       0
#define TRENCH_HEIGHTS  1   // [[x, y, originalHeight], ...] captured BEFORE the first drop
#define TRENCH_CURATOR  2
#define TRENCH_PENDING  3   // cells not yet finished; the completion toast fires at 0
#define TRENCH_TOTAL    4
#define TRENCH_CELLS    5   // the plan, kept SERVER-side. A digger is told only where to
                            // stand: CBA events copy their payload rather than sharing it,
                            // so a record handed to another machine would be mutated there
                            // and the server's own copy would never see it sink.
#define TRENCH_DIGGERS  6   // the engineers, ordered along the trench. Kept because the
                            // run is dispatched ONE CELL AT A TIME: EFUNC(common,approach)
                            // supersedes any pending order on the same lead, so handing a
                            // digger his whole run at once left every cell but the last
                            // silently abandoned before he took a step.

// The cell -> digger rule, written ONCE. Runs are CONTIGUOUS, so cell _i belongs to
// digger floor(_i * diggers / cells) and two cells are the same digger's when this
// yields the same index. FUNC(dispatchCell) sends by it and the QGVAR(cellDone)
// handler tests run continuity with it; a second copy of the rule in either place is
// the twice-written-rule shape this codebase's audits keep finding bugs in.
#define DIGGER_INDEX(i,n,total) (floor (((i) * (n)) / (total)))
