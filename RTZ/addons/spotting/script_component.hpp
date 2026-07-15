#define COMPONENT spotting
#define COMPONENT_BEAUTIFIED Spotting
#include "\x\rtz\addons\main\script_mod.hpp"

// #define DEBUG_MODE_FULL
// #define DISABLE_COMPILE_CACHE

#include "\x\rtz\addons\main\script_macros.hpp"

// Detection thresholds (fnc_spottingSystem): knowsAbout value at/above which a
// group counts as heard/known (NATO marker on the leader) vs. individually
// confirmed (wedge chevron on the member).
#define SOFT_THRESHOLD 1.0
#define HARD_THRESHOLD 1.5

// Seconds before the same group can trigger another radio contact report
// after contact on it is lost.
#define GROUP_CALLOUT_COOLDOWN 600

// Spot marker naming + wedge (individual chevron) look.
#define MKR_PREFIX "rtz_spot_"
#define WEDGE_TEXTURE "\a3\ui_f\data\gui\rsc\RscDisplayEGSpectator\UnitIcon_ca.paa"
#define WEDGE_ALPHA 0.60
#define COLOR_INCAPACITATED [0.5, 0.0, 0.5, WEDGE_ALPHA]

// Housekeeping: bound the long-lived rate-limit maps (fnc_spottingSystem).
#define BLINK_THROTTLE_CAP 128
#define BLINK_THROTTLE_WINDOW 5
#define FIRE_BLINK_THROTTLE 0.1
#define SPOT_COOLDOWN_CAP 256

// Echelon/size amplifier squad-size breakpoints (fnc_echelonTex). ~8 men per
// squad — adjust if your squads differ.
#define ECHELON_FIRETEAM_MAX 4
#define ECHELON_SQUAD_MAX 8
#define ECHELON_MULTI_SQUAD_MAX 15

// Client draw distances/sizes (fnc_spottingClient).
#define WEDGE_MAX_DIST 2500
#define CHEVRON_MAX_DIST 500
#define HOVER_MAX_DIST 50
#define HOVER_HIT_R2 (0.05 * 0.05)
#define GROUP_HOVER_R2 (0.05 * 0.05)
#define GROUP_ICON_WIDTH 1.3
#define BLINK_DURATION 0.15

// Echelon amplifier vertical gap above the group icon, indexed by side idx
// (0 = BLUFOR rectangle, 1 = OPFOR diamond — peaks highest, 2 = independent/
// civilian square). World-space (fnc_spottingClient) vs. map screen-space
// (fnc_initCuratorDisplay) use different scales.
#define AMP_GAPS_WORLD [0.002, 0.008, 0.004]
#define AMP_GAPS_MAP [0.005, 0.011, 0.005]
#define MAP_ICON_SIZE 24

// Group icon world-space height offset over camera distance — native Zeus
// group-icon recipe (fnc_spottingClient).
#define GROUP_ZMOD_NEAR 180
#define GROUP_ZMOD_FAR 360
#define GROUP_ZMOD_MIN 5
#define GROUP_ZMOD_MAX 20
#define GROUP_ZMOD_FLOOR_SCALE 0.88

// Officer editing-area zone ring overlay (fnc_initCuratorDisplay).
#define COLOR_ZONE_RING [0.25, 0.55, 1, 0.85]

// Remote-control indicator (fnc_remoteControlIndicator).
#define RC_CHECK_INTERVAL 3
#define RC_OWNER_VAR "bis_fnc_moduleRemoteControl_owner"
#define RC_TEXTURE "\a3\modules_f_curator\data\portraitremotecontrol_ca.paa"
#define RC_ICON_NEAR 500
#define RC_ICON_FAR 3000
#define RC_ICON_MAX_WIDTH 1.2
#define RC_ICON_MIN_WIDTH 0.7
#define RC_COLOR_SHIFT_MAX 0.25
#define RC_COLOR_SHIFT_FREQ 180
