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

// GVAR(incomeInterval) as the payout scheduler and the clock may use it. The
// setting's slider bottoms out at 0, and a server CBA config can set a value
// off the slider entirely, so the raw read is not safe to schedule from: at 0
// the next payout is due the instant the last one landed, which turns the
// server's income PFH into a publicVariable broadcast plus a payout of exactly
// zero points to every curator every TICK_INTERVAL, for the rest of a
// multi-hour operation. Nothing about that is visible in game — the clock just
// reads 00 forever. Floored at the tick that drives it, which is the fastest
// cadence the schedule can actually be honoured at.
#define INCOME_INTERVAL (GVAR(incomeInterval) max TICK_INTERVAL)

// RscDisplayCurator create trees whose leaves are single CfgVehicles classes.
// The group, module and marker trees have no such class and stay unhooked
#define IDC_CREATE_UNITS_WEST 270
#define IDC_CREATE_UNITS_EAST 271
#define IDC_CREATE_UNITS_GUER 272
#define IDC_CREATE_UNITS_CIV 273
#define IDC_CREATE_UNITS_EMPTY 274
#define IDC_CREATE_RECENT 282

#define IDCS_CREATE_TREES [IDC_CREATE_UNITS_WEST, IDC_CREATE_UNITS_EAST, IDC_CREATE_UNITS_GUER, IDC_CREATE_UNITS_CIV, IDC_CREATE_UNITS_EMPTY, IDC_CREATE_RECENT]

// RscDisplayCurator's feedback message control (\a3\ui_f_curator\ui\defineResinclDesign.inc),
// driven directly by FUNC(placementToast): BIS_fnc_showCuratorFeedbackMessage,
// and so zen_common_fnc_showMessage on top of it, plays an error sound on every
// call, which turns browsing the create tree into a machine gun
#define IDC_CURATOR_FEEDBACKMESSAGE 15512

// Seconds the cost stays up, then the fade-out duration. Both match the BIS
// function's own timings so the hint behaves like every other Zeus message
#define TOAST_DURATION 3
#define TOAST_FADE 0.5

// RscDisplayCurator's clock bar (\a3\ui_f_curator\ui\defineResinclDesign.inc):
// a controls group holding elapsed mission time, in-game daytime and a mission
// countdown. The countdown reads "--:--:--" for the whole operation on a mission
// with no time limit, which is the slot FUNC(incomeClockTick) borrows.
#define IDC_CURATOR_CLOCK 16808
#define IDC_CURATOR_CLOCK_DURATION 15506
#define IDC_CURATOR_CLOCK_DAYTIME 15509
#define IDC_CURATOR_CLOCK_COUNTDOWN 15511

// How often the income clock rewrites the bar. Vanilla's own cadence — see the
// "Loop" case of \a3\ui_f_curator\ui\scripts\RscDisplayCurator.sqf, which
// rate-limits all three fields on a "clocktime" variable it keeps on the
// assigned curator logic (set locally, so this costs no traffic).
#define CLOCK_INTERVAL 1

// Seconds pushed into that "clocktime" gate on every tick, which is what stops
// vanilla writing the slot back. DELIBERATELY LONGER THAN CLOCK_INTERVAL: at
// exactly one second a frame can land between the gate expiring and this
// component's PFH firing, and vanilla would win the slot for that frame — one
// visible flicker of "--:--:--" per second. Two seconds means it never wins the
// race, and still hands the bar back promptly once RTZ stops leasing it.
#define CLOCK_LEASE 2

// Income clock tint, applied only while the curator is at a FULL BAR:
// FUNC(addPoints) caps gains there, so the next payout is thrown away and the
// countdown is worth pulling the eye to. Below a full bar the readout keeps the
// control's own colour and sits quietly with the rest of the clock.
#define COLOR_INCOME [0.40, 1.00, 0.40, 1]

// Modules a curator does not get, gated behind GVAR(cleanModuleTree) in
// fnc_registerCosts. Lowercase: matched against toLowerANSI class names.
// Reinforcements: ZEN's Create LZ, Create RP and Spawn Reinforcements.
// Fire support: ZEN's CAS and Atomic Bomb modules, plus vanilla's Howitzer,
// Mortar and Rocket — all superseded by the airstrike and battery components.
// Objects: ZEN's Make Invincible.
// Ambient Flyby: ZEN's, and the one entry here no RTZ system replaces. The
// engine bills placement through the cost table this component builds, and a
// module logic has no cost — so the 1-3 crewed aircraft the flyby spawns
// server-side are never charged to anyone.
#define HIDDEN_MODULES [ \
    "zen_modules_modulecreatelz", "zen_modules_modulecreaterp", "zen_modules_modulespawnreinforcements", \
    "zen_modules_modulecasgun", "zen_modules_modulecasmissile", "zen_modules_modulecasgunmissile", "zen_modules_modulecasbomb", \
    "moduleordnancehowitzer_f", "moduleordnancemortar_f", "moduleordnancerocket_f", \
    "zen_modules_modulemakeinvincible", \
    "zen_modules_moduleambientflyby", \
    "moduleFlareGreen_F", "moduleFlareGreen_Illumination_F", "moduleFlareRed_F", "moduleFlareRed_Illumination_F", "moduleFlareYellow_F", "moduleFlareYellow_Illumination_F", "moduleFlareWhite_F", "moduleFlareWhite_Illumination_F" \
]

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
#define INDEX_TRUCK 8
#define INDEX_OFFICER 9

// Base cost per category, in points (POINTS_MAX = a full resource bar). Used as
// the fallback for classes without an explicit entry in the defaultCosts table
#define COST_INFANTRY 1
#define COST_STATIC 5
#define COST_CAR 6
#define COST_APC 15
#define COST_TRACKED 25
#define COST_HELICOPTER 20
#define COST_PLANE 30
#define COST_BOAT 10
#define COST_TRUCK 5
#define COST_OFFICER 20
