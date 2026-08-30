#define COMPONENT zubr
#define COMPONENT_BEAUTIFIED ZUBR
#include "\x\rtz\addons\main\script_mod.hpp"

// #define DEBUG_MODE_FULL
// #define DISABLE_COMPILE_CACHE

#ifdef DEBUG_ENABLED_ZUBR
    #define DEBUG_MODE_FULL
#endif

#ifdef DEBUG_SETTINGS_ZUBR
    #define DEBUG_SETTINGS DEBUG_SETTINGS_ZUBR
#endif

#include "\x\rtz\addons\main\script_macros.hpp"

// ── Engine monitor ───────────────────────────────────────────────────────────
// Base tick of the shared per-frame handler that animates every live Zubr's air
// cushion and propellers. CUP drove this from a `spawn`ed `while {alive} do` with
// a `sleep 0.05`; the rates below are per SECOND rather than per iteration, so a
// hitching frame or a starved scheduler slows the animation instead of the tick.
#define ZUBR_MONITOR_TICK 0.05

// Propeller phase advanced per second at full RPM, and how fast RPM itself winds
// up and down. CUP's figures were 0.2 and 0.01 per 0.05 s iteration.
#define PROPELLER_RATE   4
#define PROPELLER_SPIN   0.2

// Longest step the monitor will integrate in one go. Without it a frame hitch or
// a mission-time jump hands the propellers one enormous advance.
#define ZUBR_MAX_DELTA 0.5

// GVAR(monitored) record layout
#define ZUBR_VEHICLE  0
#define ZUBR_RPM      1
#define ZUBR_ENGINE   2   // last engineon_source value written, -1 = never

// ── Hull numbers ─────────────────────────────────────────────────────────────
// One format slot: the digit. Only 0, 2, 3, 5 and 7 are packed today —
// _rip/build_csat.py prunes the rest as "unreferenced", which its static scan
// cannot know is false, because the three CustomShipNumber Eden attributes build
// this path at RUNTIME from a typed number. FUNC(zubrHullNumbers) tests the
// assembled path with `fileExists` rather than against a list of the packed
// digits, so restoring the missing five needs no change here or there.
#define ZUBR_HULL_DIGIT_PATH "\x\rtz\addons\zubr\zubr_hovercraft_assets\data\num\hull_num_%1_ca.paa"

// ── Ogon manual ranging ──────────────────────────────────────────────────────
// How long the ranging fix waits for the rocket's booster to burn out before it
// scales the velocity down. CUP's figure, unchanged.
#define MISSILE_RANGING_DELAY 1.1
