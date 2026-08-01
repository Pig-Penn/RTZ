#define COMPONENT supply
#define COMPONENT_BEAUTIFIED Supply
#include "\x\rtz\addons\main\script_mod.hpp"

// #define DEBUG_MODE_FULL
// #define DISABLE_COMPILE_CACHE

#ifdef DEBUG_ENABLED_SUPPLY
    #define DEBUG_MODE_FULL
#endif

#ifdef DEBUG_SETTINGS_SUPPLY
    #define DEBUG_SETTINGS DEBUG_SETTINGS_SUPPLY
#endif

#include "\x\rtz\addons\main\script_macros.hpp"

#define ICON_RESUPPLY "\A3\ui_f\data\igui\cfg\simpletasks\types\rearm_ca.paa"

// Damage below this is treated as intact, so a scratched vehicle does not keep
// the action visible forever
#define REPAIR_THRESHOLD 0.02

// Fuel above this is treated as full
#define FUEL_THRESHOLD 0.99

// Floor (s) of the GVAR(serviceInterval) setting — the interval at which
// service progress is applied. Deliberately coarse: the loop is a single
// handler for the whole order and interpolates against the clock, so the
// interval changes write granularity, never total throughput.
#define SERVICE_TICK_MIN 0.5
