#define COMPONENT hud
#define COMPONENT_BEAUTIFIED HUD
#include "\x\rtz\addons\main\script_mod.hpp"

// #define DEBUG_MODE_FULL
// #define DISABLE_COMPILE_CACHE

#ifdef DEBUG_ENABLED_HUD
    #define DEBUG_MODE_FULL
#endif

#ifdef DEBUG_SETTINGS_HUD
    #define DEBUG_SETTINGS DEBUG_SETTINGS_HUD
#endif

#include "\x\rtz\addons\main\script_macros.hpp"

// rtz_core's public contract: RENDER_WORLD / RENDER_UI and the CTX_* frame
// context indices for the renderers below, SRC_* / SEL_MAX_* / SIDE_NUM /
// VEH_SIDE_OK for the streams. Owned by the component that implements them, and
// included here by absolute path because this component is a consumer of both.
#include "\x\rtz\addons\core\script_macros_core.hpp"

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
// The SRC_* slice constants a stream is declared with, and the SEL_MAX_* /
// SIDE_NUM / VEH_SIDE_OK rules the engine applies and the displays below must
// agree with, come from core's script_macros_core.hpp included above.
#define STREAM_UNIT 'unit'
#define STREAM_VEH  'veh'
#define STREAM_DEST 'dest'
#define STREAM_TGT  'tgt'

// ─────────────────────────────────────────────────────────────────────────────
// TAG SYSTEMS
// ─────────────────────────────────────────────────────────────────────────────
// The unit head tags and the vehicle head tags are ONE mechanism with two
// declarations (FUNC(startTagSystem)), not two parallel implementations. They
// were the latter: a pair of near-identical start functions, a pair of
// CBA_SettingChanged watchers, a pair of visible/cache/dirty global triples, and
// every consumer of those globals carrying `isNil` guards because either system
// may be switched off in settings. GVAR(tagSystems) holds one record per live
// system and the guards go with them — a system that was never started simply is
// not in the map.
//
// Record layout, keyed by system id (which is also its renderer id and its
// EFUNC(core,setDemand) consumer id — one name, so they cannot drift):
#define TAG_VISIBLE  0   // runtime show/hide, flipped by the shared context action
#define TAG_CACHE    1   // netId -> built entry, wiped whenever TAG_DIRTY is set
#define TAG_DIRTY    2   // set on a fresh packet or a settings change
#define TAG_RENDERER 3   // LINKFUNC of the RENDER_WORLD renderer
#define TAG_PRIORITY 4   // draw order within the frame loop
#define TAG_SLICES   5   // SRC_* slices this system demands from the stream engine
#define TAG_PREFIX   6   // lowercased setting-name prefix that dirties its cache
#define TAG_MASTER   7   // lowercased master enable setting

// "Is any tag system currently showing?" — a macro rather than a helper because
// FUNC(toggleTags) and FUNC(tagsContext)'s modifierFunction must agree on it
// exactly: the first hides everything when it is true, and the second labels the
// action "Hide" on the same condition. Two copies of that rule would eventually
// disagree and the button would lie about what it does.
#define ANY_TAGS_VISIBLE (((values GVAR(tagSystems)) findIf {_x select TAG_VISIBLE}) != -1)

// ─────────────────────────────────────────────────────────────────────────────
// SELECTION DIALOG
// ─────────────────────────────────────────────────────────────────────────────
// Spaced middot separator between the segments of a row / header line. Joining
// with it while dropping empty segments is FUNC(joinRow) — a function rather than
// a macro because the preprocessor splits macro arguments on commas regardless of
// square brackets, so JOIN(...) on an array literal would silently tear it apart.
#define ROW_SEP "   ·   "

// ── Named packet fields ──────────────────────────────────────────────────────
// The dialog's row builder reads the whole packet in order with `params`; these
// name the handful of fields the BUCKETING and SUMMARY paths reach for out of
// order (grouping keys, tallies, side tint), so those stay readable and survive a
// layout change. Indices are the writer's — FUNC(gatherUnitInfo)'s array order.
// Shared here rather than redefined per file now that the dialog is split across
// FUNC(buildSelectionRows) / FUNC(selectionHeader) / FUNC(groupDescriptor).
#define PKT_ISLDR   1
#define PKT_GRPID   2
#define PKT_SIDE    4
#define PKT_MORALE  9
#define PKT_FLAGS   11
#define PKT_DOWNED  12
#define PKT_TACTIC  14
#define PKT_ISLOCAL 22
#define PKT_GRPNET  24

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
// (FUNC(buildSelectionRows)) and the unit head tags (FUNC(drawUnitTags)) —
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
// placement offsets at cache-build time and FUNC(drawUnitTags) does the drawing, so
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
//
// DECONFLICT_MAX_PASSES bounds FUNC(drawUnitTags)' tag-stacking sweep. Each pass
// drops a tag clear of EVERY tag it currently overlaps at once, so one pass
// resolves the ordinary case and a second mops up an overlap the first move
// exposed; the bound is there because this runs per tag per frame and a settling
// loop is not something to leave open-ended at that rate.
#define DECONFLICT_MAX_PASSES 2
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

// MAX_DRAW_DIST / FADE_NEAR / LABEL_CURSOR_RADIUS / LABEL_TEXT_SIZE / LABEL_FONT
// come from core/script_macros_core.hpp, included above — they are the shared
// overlay draw contract, not this component's to set.

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

// NOTE: the spot-rendering and remote-control-indicator tunables moved to
// rtz_spotting's script_component.hpp along with FUNC(drawSpots) and
// FUNC(drawRcIndicator). A constant belongs to whichever component DRAWS with
// it, and those two renderers now live with the data they read — which is what
// removed the mutual rtz_hud/rtz_spotting dependency. AMP_GAPS_WORLD in
// particular is finally beside its map-space twin AMP_GAPS_MAP.
