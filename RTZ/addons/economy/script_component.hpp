#define COMPONENT economy
#define COMPONENT_BEAUTIFIED Economy
#include "\x\rtz\addons\main\script_mod.hpp"

// #define DEBUG_MODE_FULL
// #define DISABLE_COMPILE_CACHE

#ifdef DEBUG_ENABLED_ECONOMY
    #define DEBUG_MODE_FULL
#endif

#ifdef DEBUG_SETTINGS_ECONOMY
    #define DEBUG_SETTINGS DEBUG_SETTINGS_ECONOMY
#endif

#include "\x\rtz\addons\main\script_macros.hpp"

// The engine normalizes curator points to 0..1, settings use points where
// POINTS_MAX equals a full resource bar
#define POINTS_MAX 100

// Income tick and new curator module detection interval (seconds)
#define TICK_INTERVAL 5

// Cost category indices, order matches the base cost array in fnc_registerCosts
#define INDEX_FREE -1
#define INDEX_INFANTRY 0
#define INDEX_STATIC 1
#define INDEX_CAR 2
#define INDEX_APC 3
#define INDEX_TRACKED 4
#define INDEX_HELICOPTER 5
#define INDEX_PLANE 6
#define INDEX_BOAT 7
