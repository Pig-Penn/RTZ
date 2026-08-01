#define COMPONENT mine
#define COMPONENT_BEAUTIFIED Mine
#include "\x\rtz\addons\main\script_mod.hpp"

// #define DEBUG_MODE_FULL
// #define DISABLE_COMPILE_CACHE

#ifdef DEBUG_ENABLED_MINE
    #define DEBUG_MODE_FULL
#endif

#ifdef DEBUG_SETTINGS_MINE
    #define DEBUG_SETTINGS DEBUG_SETTINGS_MINE
#endif

#include "\x\rtz\addons\main\script_macros.hpp"

// How close a unit must get before planting a mine (meters)
#define PLACE_DISTANCE 2

// Radius around the context menu position in which mines are looked up (meters)
#define SEARCH_RADIUS 15

// How long the "PutDown" animation is given to play before the mine is actually
// created and the layer's own weapon is put back in his hands (seconds)
#define PUT_DELAY 1.5

// Detected mine cache refresh interval (seconds)
#define REFRESH_INTERVAL 3

// Mine marker drawing, icon is raised above the ground for 3D visibility
#define ICON_FALLBACK "\a3\ui_f\data\igui\cfg\simpleTasks\types\danger_ca.paa"
#define ICON_SIZE_3D 0.8
#define ICON_SIZE_MAP 24
#define ICON_OFFSET_Z 0.5
#define COLOR_MINE [0.9, 0.2, 0.2, 1]
