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
// Ported from ace_trenches_fnc_blockTrench_place (PabstMirror). The numbers are
// measurements of the vanilla Land_Trench_01_forest_F model, not free parameters:
// change one and the walls stop meeting the floor.
#define TRENCH_BLOCK   "Land_Trench_01_forest_F"
#define CLUTTER_CUTTER "Land_ClutterCutter_medium_F"

#define MODEL_X      2.1    // m — block half-width, decides how far the side walls sit out
#define MODEL_Z      1.1    // m — block height, feeds the scale-compensating z offset
#define MODEL_SIZE   3.75   // m — the block's native footprint; blocks are scaled by
                            // cellsize/MODEL_SIZE so one cell is spanned by one block

#define LAND_ADJUST  -1.7   // m the TERRAIN VERTEX drops. The only figure that touches
                            // the heightmap; everything else places objects.
#define TRENCH_DEPTH -1     // m the floor block sits below the side walls
#define TRENCH_WIDTH  1     // m from centre line to the inner face of each wall
#define BLOCK_ADJUST -0.45  // m — sinks the block so it sits flush rather than proud

// ── Terrain grid limits ──────────────────────────────────────────────────────
// setTerrainHeight moves heightmap VERTICES, so the smallest feature expressible is
// one cell. Below CELL_MIN the vertex spacing is finer than the block model and the
// walls overlap; above CELL_MAX a single cell is wider than the trench is long and
// the deformation reads as a crater. Altis is 7.5; ACE notes Malden is 12.5 and
// refuses it, which is why a map can legitimately be undiggable.
#define CELL_MIN      1
#define CELL_MAX     10
#define MIN_CELLS     2     // a one-cell trench has no interior vertex, so it would
                            // place blocks and deform nothing at all

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
// One cell is one unit of work: one engineer walks to CELL_CENTRE, digs, and the
// server then builds THIS cell and drops THIS cell's vertex.
//
// Every height in here is resolved at PLAN time, off pristine terrain, rather than
// read again when the cell is built. Cells share vertices with their neighbours, so
// a builder that read the live heightmap would get a different answer depending on
// which neighbour happened to finish first — and the blocks would sink further with
// each one. Resolving once makes the build order irrelevant.
#define CELL_CENTRE  0   // [x,y] — where the engineer is sent, and the preview marker
#define CELL_VERTEX  1   // [x, y, originalHeight], or [] for the two end cells, which
                         // deform nothing: dropping the outer vertices would pull the
                         // floor up out of the surrounding ground (ACE skips them too)
#define CELL_BLOCKS  2   // [[positionASL, vectorDir, vectorUp], ...] — floor, then walls
#define CELL_CUT     3   // whether this cell also gets a clutter cutter

// ── Layout of a trench record in GVAR(trenches) ──────────────────────────────
// Server-only, bounded by GVAR(maxTrenches). Holds what a future fill-in order would
// need — the ORIGINAL vertex heights and the objects created — so that order can be
// added without retrofitting the data model.
#define TRENCH_ID       0
#define TRENCH_BLOCKS   1   // objects created so far
#define TRENCH_HEIGHTS  2   // [[x, y, originalHeight], ...] captured BEFORE the drop
#define TRENCH_CURATOR  3
#define TRENCH_PENDING  4   // cells not yet built; the completion toast fires at 0
#define TRENCH_TOTAL    5
#define TRENCH_CELLS    6   // the plan, kept SERVER-side. A digger is told only where to
                            // stand: CBA events copy their payload rather than sharing it,
                            // so a record handed to another machine would be mutated there
                            // and the server's own copy would never see a block appear.
#define TRENCH_SCALE    7
#define TRENCH_DIGGERS  8   // the engineers, ordered along the trench. Kept because the
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
