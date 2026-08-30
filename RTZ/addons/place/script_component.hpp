#define COMPONENT place
#define COMPONENT_BEAUTIFIED Place
#include "\x\rtz\addons\main\script_mod.hpp"

// #define DEBUG_MODE_FULL
// #define DISABLE_COMPILE_CACHE

#ifdef DEBUG_ENABLED_PLACE
    #define DEBUG_MODE_FULL
#endif

#ifdef DEBUG_SETTINGS_PLACE
    #define DEBUG_SETTINGS DEBUG_SETTINGS_PLACE
#endif

#include "\x\rtz\addons\main\script_macros.hpp"

// Ghost icons draw through rtz_core's ONE Draw3D handler, so this component
// needs that contract (RENDER_WORLD, CTX_*).
#include "\x\rtz\addons\core\script_macros_core.hpp"

// ── Layout of a ghost in GVAR(ghosts) ────────────────────────────────────────
// One record per unit taking part, on the CURATOR'S CLIENT only — nothing here
// is authoritative and no unit moves until FUNC(commitPlacement) runs. An array
// of records rather than a HashMap: the renderer walks all of them every frame,
// which is the shape an array already is, and the only keyed lookup (the hovered
// index) is produced by that same walk. Same reasoning and the same
// macro-indexed layout as rtz_path's GVAR(paths).
//
// GHOST_HELPER is the hidden Logic the ghost rides and is ALSO the authoritative
// position of the record: FUNC(commitPlacement) reads getPosASL off it and moves
// the unit there verbatim. GHOST_MODEL is objNull above GVAR(ghostModelMax),
// where the icons alone stand in for the ghosts.
//
// GHOST_ORIGIN is where the unit STOOD when the session opened — not where its
// ghost was seeded. It is what the range gate measures from, in both the renderer
// and the commit, so the gate asks "how far would this unit actually travel"
// rather than "how far has the ghost been dragged since it appeared". Seeding
// already moves a ghost most of the way to the cursor, so measuring from the seed
// would let a unit be sent any distance at all in one hop.
//
// GHOST_LABEL, GHOST_COLORS and GHOST_GLYPH are built once, at seed time, and
// never rebuilt. CLAUDE.md: keep format/str off anything that runs per entity per
// tick, and the renderer is exactly that. GHOST_COLORS holds this unit's side
// colour at both alphas as [idle, hovered], so the renderer picks one by index
// instead of building an array per ghost per frame; the out-of-range colour is a
// constant and needs no entry. GHOST_GLYPH is the unit's own Zeus tree icon,
// drawn inside the ring by EFUNC(common,drawZeusIcon) — a config read, so it is
// resolved here rather than per ghost per frame.
#define GHOST_UNIT   0
#define GHOST_HELPER 1
#define GHOST_MODEL  2
#define GHOST_ORIGIN 3
#define GHOST_LABEL  4
#define GHOST_COLORS 5
#define GHOST_GLYPH  6

// ── Input ────────────────────────────────────────────────────────────────────
// DirectInput scancodes for the keys the session's KeyDown handler swallows.
// Both Enter keys, because a curator reaching for "confirm" hits whichever one
// their hand is nearest and a mode that only answers to one of them reads as
// broken.
#define DIK_ESCAPE      0x01
#define DIK_RETURN      0x1C
#define DIK_NUMPADENTER 0x9C

// ── Drawing ──────────────────────────────────────────────────────────────────
// Priority on rtz_core's world pass. Sits above rtz_airstrike and rtz_dig (60)
// and below rtz_path (65): a placement session and a planning session cannot be
// open at once, so the only thing this ordering decides is that ghosts draw over
// the persistent overlays rather than under them.
#define RENDER_PRIORITY 62

// The ghost marker itself is EFUNC(common,drawZeusIcon) — vanilla Zeus' own
// disc/ring/glyph composite, at a constant apparent size. Shared with rtz_common's
// placement preview so a ghost here and a ghost from a context-menu placement
// read as the same kind of object, and so both read as Zeus. Only the label size
// is this component's to set.
#define GHOST_TEXT_SIZE 0.03

// The move-order icon flashed on each unit once it has actually been moved —
// ZEN's own expected-destination glyph, the same one the teleport this mode
// replaces used, for the same length of time.
#define ICON_PLACED "\a3\ui_f\data\igui\cfg\simpleTasks\types\move_ca.paa"
#define HINT_DURATION 3

// How close, in UI units, the cursor has to come to a ghost's projected position
// to count as hovering it. Screen space, not metres, so a distant ghost is no
// harder to grab than a near one. 0.04 is a little over a ghost marker's own
// on-screen radius — exactly that, at every zoom, now the marker holds a constant
// apparent size — generous enough to grab without pixel-hunting, tight enough
// that two men standing together stay separable.
#define HOVER_RADIUS 0.04

// Colours. Alpha carries the state: a ghost the cursor is over is drawn at full
// strength, the rest are dimmed, and one dragged beyond the range gate goes red
// so the curator sees it will be refused BEFORE committing rather than reading
// about it afterwards.
#define GHOST_ALPHA_HOVER 1
#define GHOST_ALPHA_IDLE 0.65
#define COLOR_OUT_OF_RANGE [1, 0.3, 0.2, 1]
