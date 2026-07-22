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
// (FUNC(vehicleDataStream)), and the bottom-right card render
// (FUNC(vehicleOverlay)) so they never disagree.
#define SEL_MAX_VEHICLES 8

// Side index used throughout the addon's packets: 0 west, 1 east, 2 independent,
// 3 everything else (civilian / logic / sideEmpty). Computed on the server where
// the real side is known, then carried in each packet for the client to colour by.
#define SIDE_NUM(s) (switch (s) do { case west: {0}; case east: {1}; case independent: {2}; default {3} })

// Bright per-side UI palette, indexed by SIDE_NUM. ONE source of truth for both
// the selection dialog's group-separator tint and the vehicle overlay cards, so
// the two overlays always read as the same colour system. SIDE_TINTS (rgba, for
// engine draw/listbox colour) and SIDE_HEXES (structured-text markup) are the
// same four colours in the two formats the two render paths need.
#define SIDE_TINTS [[0.36, 0.61, 1.00, 1], [1.00, 0.42, 0.42, 1], [0.44, 0.85, 0.34, 1], [0.78, 0.49, 0.92, 1]]
#define SIDE_HEXES ["#5B9BFF", "#FF6B6B", "#6FD957", "#C77DEB"]

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
#define HEX_BAD    "#FF6161"

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

// Base tick (s) of the server gather PFHs, shared by the infantry gather
// (FUNC(selectionInfo)) and the vehicle gather (FUNC(vehicleDataStream)).
// The effective cadence is the GVAR(gatherInterval) CBA setting, read live
// each tick and floored to this value — this is the fastest it can go.
#define GATHER_TICK 0.25

// LAMBS danger-cause labels, indexed by dangerType + 2 (-2 Forced AI … 10
// Assessing; out of range → ""). Mirrors lambs_main_fnc_debugDangerType,
// inlined so the addon never hard-depends on LAMBS.
#define DANGER_LABELS ["Forced AI", "", "Enemy Detected", "Fire", "Hit", "Enemy Near", "Explosion", "Friendly Dead", "Dead Body", "Scream Heard", "Can Fire", "Bullet Close", "Assessing"]
