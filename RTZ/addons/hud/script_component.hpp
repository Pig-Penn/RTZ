#define COMPONENT hud
#define COMPONENT_BEAUTIFIED HUD
#include "\x\rtz\addons\main\script_mod.hpp"
// #define DEBUG_MODE_FULL
// #define DISABLE_COMPILE_CACHE
#include "\x\rtz\addons\main\script_macros.hpp"

// NOTE: the frame-loop contract this component implements — RENDER_WORLD /
// RENDER_UI and the CTX_* frame-context indices — lives in main's
// script_macros.hpp, not here. Any component may register a renderer, and
// component headers are not visible to each other.

// ─────────────────────────────────────────────────────────────────────────────
// STREAM ENGINE
// ─────────────────────────────────────────────────────────────────────────────
// A "stream" is one curator-scoped data feed: an id, a server gather function,
// the slice of the selection it reads, and a cadence. EFUNC(core,streamServer) owns
// the single watcher registry and the single poll loop; a new display costs a
// gather/draw pair and one EFUNC(core,registerStream) call, never another copy of the
// subscribe/diff/push machinery.
// SINGLE-quoted deliberately: these ids appear inside QUOTE(...) in
// CfgContext.hpp, and a double-quoted literal would terminate the config string
// the macro builds (docs/Knowledge Base/Gotchas.md §5).
// The SRC_* slice constants a stream is declared with live in main's
// script_macros.hpp, alongside the frame-loop contract — any component may
// declare a stream, and component headers are not visible to each other.
#define STREAM_UNIT 'unit'
#define STREAM_VEH  'veh'
#define STREAM_DEST 'dest'
#define STREAM_TGT  'tgt'

// NOTE: SEL_MAX_UNITS / SEL_MAX_VEHICLES / SIDE_NUM / VEH_SIDE_OK are NOT here.
// The stream engine applies them and the displays below must agree, so they live
// in main.s script_macros.hpp alongside the RENDER_* / CTX_* / SRC_* contracts --
// component headers are not visible to each other.

// Bright per-side UI palette, indexed by SIDE_NUM — the selection dialog's
// group-separator tint.
#define SIDE_TINTS [[0.36, 0.61, 1.00, 1], [1.00, 0.42, 0.42, 1], [0.44, 0.85, 0.34, 1], [0.78, 0.49, 0.92, 1]]

// Shared status palette — one urgency colour system across the selection dialog
// rows and the unit head tags. RGBA, for engine draw / listbox colour.
#define COL_NORMAL [0.88, 0.95, 1.00, 1.0]
#define COL_DIM    [0.55, 0.55, 0.55, 1.0]
#define COL_WARN   [1.00, 0.78, 0.30, 1.0]
#define COL_BAD    [1.00, 0.38, 0.38, 1.0]
#define COL_GOLD   [1.00, 0.84, 0.40, 1.0]

// BIS simpletask icon family shared by the selection dialog rows
// (FUNC(buildSelectionRows)) and the unit head tags (FUNC(unitTags)) —
// direct texture paths; CfgMarkers lookups can silently return "". FLAG_ICON
// is the flag-inventory marker texture (unit tags only).
#define ICON_ATTACK  "\a3\ui_f\data\igui\cfg\simpletasks\types\attack_ca.paa"
#define ICON_SEARCH  "\a3\ui_f\data\igui\cfg\simpletasks\types\search_ca.paa"
#define ICON_MOVE    "\a3\ui_f\data\igui\cfg\simpletasks\types\move_ca.paa"
#define ICON_HEAL    "\a3\ui_f\data\igui\cfg\simpletasks\types\heal_ca.paa"
#define ICON_RUN     "\a3\ui_f\data\igui\cfg\simpletasks\types\run_ca.paa"
#define ICON_GETIN   "\a3\ui_f\data\igui\cfg\simpletasks\types\getin_ca.paa"
#define ICON_DANGER  "\a3\ui_f\data\igui\cfg\simpletasks\types\danger_ca.paa"
#define ICON_TARGET  "\a3\ui_f\data\igui\cfg\simpletasks\types\target_ca.paa"
#define ICON_UNKNOWN "\a3\ui_f\data\igui\cfg\simpletasks\types\unknown_ca.paa"
#define FLAG_ICON    "\a3\ui_f\data\map\markers\military\flag_ca.paa"

// ── Unit tag icon geometry ───────────────────────────────────────────────────
// One tuned set, split across two files: FUNC(buildTagEntry) measures the icon
// placement offsets at cache-build time and FUNC(unitTags) does the drawing, so
// they must agree or icons land off their measured slots. All are multiples of
// the tag's text size so icons scale WITH it (the original draw pass used a fixed
// 0.7 regardless of Tag Size, leaving large tags with postage-stamp icons).
//   ICON_DRAW      drawIcon3D render size
//   ICON_FOOT      icon's on-screen footprint (UI-x), used to butt icons flush
//   ICON_TEXT_GAP  larger gap between the text and its first icon, so a status
//                  word like DOWN isn't cramped against the icon beside it
//   ICON_GAP       tighter gap between two adjacent icons
// Tuned so the default (size 0.03) reproduces the old ~0.7 icon — nudge FOOT /
// TEXT_GAP / GAP if icons overlap or drift at your UI scale.
// ICON_HOVER_RADIUS is the Zeus-cursor pick distance (UI coordinates) for an
// icon's hover-expand.
#define ICON_DRAW          23
#define ICON_FOOT          1.1
#define ICON_TEXT_GAP      0.9
#define ICON_GAP           0.3
#define ICON_HOVER_RADIUS  0.03

// ── Status-flag tokens ───────────────────────────────────────────────────────
// The flags[] field of both packet layouts. These are WIRE values, not display
// text: the server writes them, the client tests them (FLAG_FLEEING in _flags)
// and looks each one's localized label up in GVAR(tagLabels) at render time.
// Never print a token directly — that is what put untranslatable English in the
// tags in the first place.
#define FLAG_PATH_OFF "PATH OFF"
#define FLAG_MOVE_OFF "MOVE OFF"
#define FLAG_FORCED   "FORCED"
#define FLAG_FLEEING  "FLEEING"
#define FLAG_HIDDEN   "HIDDEN"
#define FLAG_INSIDE   "INSIDE"
#define FLAG_BUSY     "BUSY"
#define FLAG_MOUNTED  "MOUNTED"
#define FLAG_WOUNDED  "WOUNDED"
#define FLAG_LOW_FUEL "LOW FUEL"
#define FLAG_DAMAGED  "DAMAGED"

// RTZ-owned status words, same wire-token treatment as the flags above: the
// dialog and the tags each resolve them to display text at render time
// (FUNC(loadTagLabels) for the tags, LLSTRING directly for the dialog).
#define STATUS_DOWN "DOWN"

// ── LAMBS danger-cause labels ────────────────────────────────────────────────
// Stringtable keys indexed by dangerType + 2 (-2 Forced AI … 10 Assessing; out
// of range → ""). Mirrors lambs_main_fnc_debugDangerType, inlined so the addon
// never hard-depends on LAMBS. Index 1 is LAMBS' "No Danger", deliberately
// blank so a calm unit shows nothing rather than a redundant label.
// Localized ONCE into GVAR(dangerLabels) at preInit — never localize these per
// row/per frame; the render paths read that array.
// Kept on one line on purpose: a stray space after a line-continuation `\`
// silently truncates the macro (see docs/Knowledge Base/Gotchas.md §6).
#define DANGER_LABEL_KEYS [LSTRING(DangerForcedAI), "", LSTRING(DangerEnemyDetected), LSTRING(DangerFire), LSTRING(DangerHit), LSTRING(DangerEnemyNear), LSTRING(DangerExplosion), LSTRING(DangerFriendlyDead), LSTRING(DangerDeadBody), LSTRING(DangerScreamHeard), LSTRING(DangerCanFire), LSTRING(DangerBulletClose), LSTRING(DangerAssessing)]

// ─────────────────────────────────────────────────────────────────────────────
// AI-STATE OVERLAYS (destination / target streams)
// ─────────────────────────────────────────────────────────────────────────────
// Context-action icons and their idle tints. The labels and tints themselves are
// resolved by EFUNC(core,overlayActionModifier) from the stream id — localize inside a
// QUOTE would hit the nested-quote problem (docs/Knowledge Base/Gotchas.md §5) — and a running
// overlay goes grey regardless of which one it is.
#define ICON_DEST "\a3\ui_f\data\igui\cfg\simpletasks\types\move_ca.paa"
#define ICON_TGT  "\a3\ui_f\data\igui\cfg\simpletasks\types\kill_ca.paa"
#define COLOR_DEST [1.00, 0.80, 0.40, 1]
#define COLOR_TGT  [0.60, 0.20, 0.20, 1]

// Overlays start fading at FADE_NEAR and bottom out at MAX_DRAW_DIST (matches
// the spotting wedge outer cap); labels only render while the cursor is within
// LABEL_CURSOR_RADIUS of the icon (GUI screen units).
#define MAX_DRAW_DIST       2500
#define FADE_NEAR           800
#define LABEL_CURSOR_RADIUS 0.05
#define LABEL_TEXT_SIZE     0.03
#define LABEL_FONT          "RobotoCondensed"

// Server-side sanity cap (m) on unit → destination / estimated-target
// distance — mirrors the LAMBS debug renderer's cap.
#define KNOWLEDGE_MAX_DIST  6000

// FUNC(drawDestination): the line drops once the unit has effectively arrived.
// Icons swap foot/vehicle by unit type; when GVAR(destGrowWithSpeed) is on the
// size ramps DEST_SIZE_MIN→DEST_SIZE_MAX across 0→DEST_SPEED_MAX km/h (the LAMBS
// debug look), otherwise it holds at DEST_SIZE_FIXED.
// NOTE the DEST_ prefixes: this component also carries the unit-tag icon
// geometry above, where ICON_FOOT is a UI-x footprint and ICON_TARGET is the
// tag's target texture. Merging the two files collided on both names, and a
// silently redefined texture path renders as a missing icon rather than an
// error — so the overlay set is namespaced.
#define ARRIVE_RADIUS       3
#define ICON_DEST_FOOT      "\a3\ui_f\data\igui\cfg\simpletasks\types\walk_ca.paa"
#define ICON_DEST_VEHICLE   "\a3\ui_f\data\igui\cfg\simpletasks\types\car_ca.paa"
#define DEST_SPEED_MAX      30
#define DEST_SIZE_MIN       0.3
#define DEST_SIZE_MAX       0.9
#define DEST_SIZE_FIXED     0.65

// FUNC(drawTarget): how long (s) after the last sighting the overlay bottoms out
// at its dimmest — old intel visibly recedes. Aged client-side every frame from
// the snapshot's reference time, so the dim fades instead of stepping once per
// poll.
#define STALE_DIM_TIME      30
#define ICON_TGT_MARK       "\a3\ui_f\data\igui\cfg\targeting\impactpoint_ca.paa"
#define TGT_SIZE            0.9

// ─────────────────────────────────────────────────────────────────────────────
// SPOT RENDERING (data produced by rtz_spotting's server detection pass)
// ─────────────────────────────────────────────────────────────────────────────
// rtz_spotting decides WHAT is spotted; this component decides how it looks.
// Draw distances/sizes for FUNC(drawSpots).
#define WEDGE_MAX_DIST 2500
#define CHEVRON_MAX_DIST 500
// Chevron icon width ramp: CHEVRON_W_NEAR at the camera, tapering to
// CHEVRON_W_FAR at WEDGE_MAX_DIST.
#define CHEVRON_W_NEAR 4
#define CHEVRON_W_FAR 2
#define HOVER_MAX_DIST 50
#define HOVER_HIT_R2 (0.05 * 0.05)
#define GROUP_HOVER_R2 (0.05 * 0.05)
#define GROUP_ICON_WIDTH 1.3

// Echelon amplifier vertical gap above the group icon, indexed by side idx
// (0 = BLUFOR rectangle, 1 = OPFOR diamond — peaks highest, 2 = independent/
// civilian square), in world space (FUNC(drawSpots)).
//
// The map screen-space twin (AMP_GAPS_MAP, MAP_ICON_SIZE) belongs to
// rtz_spotting, which owns the Zeus MAP overlay; it sat here as a dead copy after
// the rtz_hud split and tuning it did nothing. A constant belongs to whichever
// component DRAWS with it — the blink duration, the RC scan cadence and the RC
// owner variable are likewise rtz_spotting's, since that component detects; this
// one only renders what it is told.
#define AMP_GAPS_WORLD [0.002, 0.008, 0.004]

// Group icon world-space height offset over camera distance — native Zeus
// group-icon recipe (FUNC(drawSpots)).
#define GROUP_ZMOD_NEAR 180
#define GROUP_ZMOD_FAR 360
#define GROUP_ZMOD_MIN 5
#define GROUP_ZMOD_MAX 20
#define GROUP_ZMOD_FLOOR_SCALE 0.88

// ─────────────────────────────────────────────────────────────────────────────
// REMOTE-CONTROL INDICATOR — look only; the scan that feeds it is rtz_spotting's.
// ─────────────────────────────────────────────────────────────────────────────
#define RC_TEXTURE "\a3\modules_f_curator\data\portraitremotecontrol_ca.paa"
#define RC_ICON_NEAR 500
#define RC_ICON_FAR 3000
#define RC_ICON_MAX_WIDTH 1.2
#define RC_ICON_MIN_WIDTH 0.7
#define RC_COLOR_SHIFT_MAX 0.25
#define RC_COLOR_SHIFT_FREQ 180
