#define COMPONENT overlays
#define COMPONENT_BEAUTIFIED Overlays
#include "\x\rtz\addons\main\script_mod.hpp"

// #define DEBUG_MODE_FULL
// #define DISABLE_COMPILE_CACHE

#ifdef DEBUG_ENABLED_OVERLAYS
    #define DEBUG_MODE_FULL
#endif

#ifdef DEBUG_SETTINGS_OVERLAYS
    #define DEBUG_SETTINGS DEBUG_SETTINGS_OVERLAYS
#endif

#include "\x\rtz\addons\main\script_macros.hpp"

// ── Stream ids ───────────────────────────────────────────────────────────────
// Both overlays ride ONE pipeline (FUNC(streamClient) / FUNC(streamServer)):
// one Draw3D handler, one server poll, one watcher registry, one subscribe /
// snapshot event pair. A stream is just an id plus the gather + draw function
// pair registered against it, so a third overlay costs two small functions and
// a CfgContext entry — not another copy of the machinery.
// SINGLE-quoted deliberately: these ids appear inside QUOTE(...) in
// CfgContext.hpp, and a double-quoted literal would terminate the config string
// the macro builds.
#define STREAM_DEST 'dest'
#define STREAM_TGT  'tgt'

// Context-action icons and their idle tints. The labels and tints themselves are
// resolved by FUNC(overlayActionModifier) from the stream id — localize inside a
// QUOTE would hit the same nested-quote problem — and a running overlay goes
// grey regardless of which one it is.
#define ICON_DEST "\a3\ui_f\data\igui\cfg\simpletasks\types\move_ca.paa"
#define ICON_TGT  "\a3\ui_f\data\igui\cfg\simpletasks\types\kill_ca.paa"
#define COLOR_DEST [1.00, 0.80, 0.40, 1]
#define COLOR_TGT  [0.60, 0.20, 0.20, 1]
#define COLOR_OVERLAY_ON [0.50, 0.50, 0.50, 1]

// ── Shared draw constants (fnc_drawDestination / fnc_drawTarget) ─────────────
// Overlays start fading at FADE_NEAR and bottom out at MAX_DRAW_DIST (matches
// the spotting wedge outer cap); labels only render while the cursor is within
// LABEL_CURSOR_RADIUS of the icon (GUI screen units).
#define MAX_DRAW_DIST       2500
#define FADE_NEAR           800
#define LABEL_CURSOR_RADIUS 0.05
#define LABEL_TEXT_SIZE     0.03
#define LABEL_FONT          "RobotoCondensed"

// Base tick (s) of the server poll PFHs for both overlay streams. The
// effective cadence is the GVAR(pollInterval) CBA setting (default 2 s — one
// targetEvent per watcher per tick, tracks contact without flooding the
// network), read live each tick and floored to this value.
#define POLL_TICK           0.5

// Server-side sanity cap (m) on unit → destination / estimated-target
// distance — mirrors the LAMBS debug renderer's cap.
#define KNOWLEDGE_MAX_DIST  6000

// fnc_drawDestination: the line drops once the unit has effectively
// arrived. Icons swap foot/vehicle by unit type; when GVAR(destGrowWithSpeed)
// is on the size ramps ICON_SIZE_MIN→ICON_SIZE_MAX across 0→ICON_SPEED_MAX
// km/h (the LAMBS debug look), otherwise it holds at ICON_SIZE_FIXED.
#define ARRIVE_RADIUS       3
#define ICON_FOOT           "\a3\ui_f\data\igui\cfg\simpletasks\types\walk_ca.paa"
#define ICON_VEHICLE        "\a3\ui_f\data\igui\cfg\simpletasks\types\car_ca.paa"
#define ICON_SPEED_MAX      30
#define ICON_SIZE_MIN       0.3
#define ICON_SIZE_MAX       0.9
#define ICON_SIZE_FIXED     0.65

// fnc_drawTarget: how long (s) after the last sighting the overlay bottoms
// out at its dimmest — old intel visibly recedes. Aged client-side every frame
// from the snapshot's reference time, so the dim fades instead of stepping once
// per poll.
#define STALE_DIM_TIME      30
#define ICON_TARGET         "\a3\ui_f\data\igui\cfg\targeting\impactpoint_ca.paa"
#define ICON_SIZE_TARGET    0.9
