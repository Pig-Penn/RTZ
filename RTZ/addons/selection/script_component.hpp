#define COMPONENT selection
#define COMPONENT_BEAUTIFIED Selection
#include "\x\rtz\addons\main\script_mod.hpp"
// #define DEBUG_MODE_FULL
// #define DISABLE_COMPILE_CACHE
#include "\x\rtz\addons\main\script_macros.hpp"

// Cap on selected infantry reported by the client poll, gathered by the server,
// and rendered by the dialog — one define keeps all three stages in lockstep.
#define SEL_MAX_UNITS 24

// Same idea for vehicles: capped in the client poll, the server gather
// (FUNC(gatherVehicleInfo)), and the bottom-right card render
// (FUNC(vehicleOverlay)) so they never disagree.
#define SEL_MAX_VEHICLES 8

// Side index used throughout the addon's packets: 0 west, 1 east, 2 independent,
// 3 everything else (civilian / logic / sideEmpty). Computed on the server where
// the real side is known, then carried in each packet for the client to colour by.
#define SIDE_NUM(s) (switch (s) do { case west: {0}; case east: {1}; case independent: {2}; default {3} })

// A vehicle's effective side is its CREW's side — but an unmanned vehicle has
// `grpNull` for a group, and `side grpNull` matches no real side, so a plain
// `side (group _veh) == side _curator` test silently hides every parked truck
// and unmanned static from a side-restricted curator. Crewless vehicles are
// treated as visible to everyone instead (they belong to nobody yet, and Zeus
// can edit them regardless). Used by the client poll, the server gather, and
// both vehicle render paths so all four agree on what is visible.
#define VEH_SIDE_OK(veh,curSide) (isNull (group veh) || { side (group veh) == curSide })

// Bright per-side UI palette, indexed by SIDE_NUM. ONE source of truth for both
// the selection dialog's group-separator tint and the vehicle overlay cards, so
// the two overlays always read as the same colour system.
#define SIDE_TINTS [[0.36, 0.61, 1.00, 1], [1.00, 0.42, 0.42, 1], [0.44, 0.85, 0.34, 1], [0.78, 0.49, 0.92, 1]]

// Shared status palette — one urgency colour system across the selection dialog
// rows, the unit head tags, and the vehicle overlay cards. RGBA for engine
// draw / listbox colour; the HEX_* set is the same colours (plus body-text
// shades) for structured-text markup.
#define COL_NORMAL [0.88, 0.95, 1.00, 1.0]
#define COL_DIM    [0.55, 0.55, 0.55, 1.0]
#define COL_WARN   [1.00, 0.78, 0.30, 1.0]
#define COL_BAD    [1.00, 0.38, 0.38, 1.0]
#define COL_GOLD   [1.00, 0.84, 0.40, 1.0]
#define HEX_BODY   "#D9DDE1"
#define HEX_DIM    "#8A9096"
#define HEX_TASK   "#9FB8C8"
#define HEX_WARN   "#FFC74D"

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

// ── Vehicle overlay card geometry (absolute UI units) and card colours ───────
// Shared by FUNC(vehicleOverlay) (stacking), FUNC(vehicleCardCreate) (control
// backgrounds) and FUNC(vehicleCardLayout) (positioning) — one set of numbers so
// the three cannot drift out of agreement about a card's shape.
#define CARD_W    0.225
#define ACCENT_W  0.0045
#define TITLE_H   0.0320
#define PAD_X     0.0080
#define BAR_H     0.0165
#define BAR_GAP   0.0045
#define CARD_GAP  0.0100
#define CARD_BG   [0, 0, 0, 0.65]
#define BAR_BG    [1, 1, 1, 0.10]

// Base tick (s) of the server gather PFHs, shared by the infantry gather
// (FUNC(selectionInfo)) and the vehicle gather (FUNC(vehicleDataStream)).
// The effective cadence is the GVAR(gatherInterval) CBA setting, read live
// each tick and floored to this value — this is the fastest it can go.
#define GATHER_TICK 0.25

// ── Status-flag tokens ───────────────────────────────────────────────────────
// The flags[] field of both packet layouts. These are WIRE values, not display
// text: the server writes them, the client tests them (FLAG_FLEEING in _flags)
// and looks each one's localized label up in GVAR(tagLabels) at render time.
// Never print a token directly — that is what put untranslatable English in the
// tags and cards in the first place.
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
// silently truncates the macro (see docs/Gotchas.md §6).
#define DANGER_LABEL_KEYS [LSTRING(DangerForcedAI), "", LSTRING(DangerEnemyDetected), LSTRING(DangerFire), LSTRING(DangerHit), LSTRING(DangerEnemyNear), LSTRING(DangerExplosion), LSTRING(DangerFriendlyDead), LSTRING(DangerDeadBody), LSTRING(DangerScreamHeard), LSTRING(DangerCanFire), LSTRING(DangerBulletClose), LSTRING(DangerAssessing)]
