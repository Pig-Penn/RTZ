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
