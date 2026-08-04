#define COMPONENT control
#define COMPONENT_BEAUTIFIED Control
#include "\x\rtz\addons\main\script_mod.hpp"

// #define DEBUG_MODE_FULL
// #define DISABLE_COMPILE_CACHE

#ifdef DEBUG_ENABLED_CONTROL
    #define DEBUG_MODE_FULL
#endif

#ifdef DEBUG_SETTINGS_CONTROL
    #define DEBUG_SETTINGS DEBUG_SETTINGS_CONTROL
#endif

#include "\x\rtz\addons\main\script_macros.hpp"

// Toggle icon/tint pair for the "Disable/Enable Simulation" context action and
// its modifierFunction.
#define ICON_HIDE "\x\rtz\addons\control\ui\pause_ca.paa"
#define ICON_SHOW "\x\rtz\addons\control\ui\play_ca.paa"
// Orange
#define COLOR_HIDE [1.00, 0.60, 0.20, 1]
// Green
#define COLOR_SHOW [0.40, 1.00, 0.40, 1]

// Third state for the same action: a group still under the editor-placed
// Dynamic Simulation system. Reuses ICON_SHOW (blue tint) rather than a new
// asset — clicking it turns Dynamic Simulation off, after which the toggle
// above reverts to its normal orange/green behaviour.
// Blue
#define COLOR_DYNSIM [0.20, 0.60, 1.00, 1]

#define ICON_OWNERSHIP "\x\zen\addons\context_actions\ui\add_ca.paa"
#define ICON_RESET "\a3\3DEN\Data\CfgWaypoints\cycle_ca.paa"
#define ICON_RELOAD "\a3\ui_f\data\IGUI\Cfg\Actions\reammo_ca.paa"

// Toggle icon/tint pair for the "Forbid/Allow Dismount" context action and its
// modifierFunction — amber padlock while vanilla (will lock crew in), cyan
// unlock once locked (will release).
#define ICON_LOCKED "\a3\modules_f\data\iconlock_ca.paa"
#define ICON_UNLOCKED "\a3\modules_f\data\iconunlock_ca.paa"
// Amber
#define COLOR_LOCKED [1.00, 0.78, 0.22, 1]
// Cyan
#define COLOR_UNLOCKED [0.40, 0.80, 1.00, 1]
