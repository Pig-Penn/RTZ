#define COMPONENT officer
#define COMPONENT_BEAUTIFIED Officer
#include "\x\rtz\addons\main\script_mod.hpp"

// #define DEBUG_MODE_FULL
// #define DISABLE_COMPILE_CACHE

#include "\x\rtz\addons\main\script_macros.hpp"

// Editing-area IDs allocated by this client start here. IDs only need to be
// unique per curator module, so every client using the same base is fine.
#define AREA_ID_BASE 1000

// Seconds between lifecycle/prune/follow passes of FUNC(monitorAreas)
#define MONITOR_INTERVAL 10

// Seconds an officer must wait after his area is removed before a new one can be placed
#define COOLDOWN_DURATION 15

// Seconds between hold/release passes of FUNC(monitorAuras) (server-side)
#define AURA_INTERVAL 10

// Context-menu icon and tint per toggle state
#define ICON_ADD "\x\zen\addons\context_actions\ui\add_ca.paa"
#define ICON_REMOVE "\x\zen\addons\context_actions\ui\remove_ca.paa"
#define COLOR_ADD_ZONE [0.4, 1, 0.4, 1]
#define COLOR_ADD_AURA [0.3, 0.7, 0.7, 1]
#define COLOR_REMOVE [1, 0.55, 0.61, 1]
#define COLOR_COOLDOWN [0.6, 0.6, 0.6, 1]

// Command-aura radius ring drawn on the Zeus map (FUNC(initCuratorDisplay))
#define COLOR_AURA_RING [0.3, 0.7, 0.7, 0.85]
