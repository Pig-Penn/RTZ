#define COMPONENT attack
#define COMPONENT_BEAUTIFIED Attack
#include "\x\rtz\addons\main\script_mod.hpp"

// #define DEBUG_MODE_FULL
// #define DISABLE_COMPILE_CACHE

#ifdef DEBUG_ENABLED_ATTACK
    #define DEBUG_MODE_FULL
#endif

#ifdef DEBUG_SETTINGS_ATTACK
    #define DEBUG_SETTINGS DEBUG_SETTINGS_ATTACK
#endif

#include "\x\rtz\addons\main\script_macros.hpp"

// Radius around the cursor position in which targets are looked up (meters)
#define SEARCH_RADIUS 15

// How accurately the ordered group knows the revealed target (0..4)
#define REVEAL_ACCURACY 4

// Sides are hostile below this getFriend value (engine threshold)
#define HOSTILE_THRESHOLD 0.6

// How long (s) FUNC(addWaypoint) watches a live DESTROY target for the one case
// the engine does not resolve on its own: a target DELETED by Zeus, which leaves
// the group holding a waypoint attached to nothing. The watch is a per-frame
// condition, so it is bounded rather than left running for the whole mission —
// a target still alive after this long is the engine's problem, not an orphan.
// Generous: an attack order that takes longer than this to resolve has already
// been superseded or forgotten.
#define ORPHAN_WATCH_TIMEOUT 600

// Order feedback drawing
#define HINT_DURATION 3
#define ICON_ATTACK "\a3\3DEN\Data\CfgWaypoints\destroy_ca.paa"
#define COLOR_TARGET [0.9, 0.2, 0.2, 1]
#define COLOR_INVALID [0.5, 0.5, 0.5, 0.8]
