#define COMPONENT common
#define COMPONENT_BEAUTIFIED Common
#include "\x\rtz\addons\main\script_mod.hpp"

// #define DEBUG_MODE_FULL
// #define DISABLE_COMPILE_CACHE

#ifdef DEBUG_ENABLED_COMMON
    #define DEBUG_MODE_FULL
#endif

#ifdef DEBUG_SETTINGS_COMMON
    #define DEBUG_SETTINGS DEBUG_SETTINGS_COMMON
#endif

#include "\x\rtz\addons\main\script_macros.hpp"

// CHECK_CURATOR_INPUT moved to main's script_macros.hpp — rtz_reverse binds a
// key too, and component script_component.hpp files cannot see each other.

// Sentinel returned by the skill table for classes without an entry
#define SKILL_NONE -1

// FUNC(sideColor) palette index for a side with no entry of its own (civilian)
#define SIDE_COLOR_DEFAULT 4

// Zeus feedback hint duration in seconds
#define HINT_DURATION 3

// Minimum helicopter fly-in height orderable by the fly-height keybinds
#define FLY_HEIGHT_MIN 0

// Move-order icon drawn by the unit teleport (ZEN's expected-destination texture)
#define ICON_TELEPORT "\a3\ui_f\data\igui\cfg\simpleTasks\types\move_ca.paa"

// Default 3D icon drawn at the spot by the placement preview picker, and the
// size it and its hint text are drawn at
#define ICON_PREVIEW "\a3\ui_f\data\igui\cfg\cursors\select_target_ca.paa"
#define PREVIEW_ICON_SIZE 1.2
#define PREVIEW_TEXT_SIZE 0.03

// Context action icon for the deploy-countermeasures order (ZEN's smoke module texture)
#define ICON_SMOKE "\x\zen\addons\modules\ui\smoke_pillar_ca.paa"

// Icons for the shared context-menu submenu anchors (CfgZenContext.hpp)
#define ICON_SUBMENU_OVERLAYS "\a3\ui_f\data\igui\cfg\simpletasks\types\documents_ca.paa"
#define ICON_SUBMENU_CONTROL "\a3\ui_f\data\igui\cfg\simpletasks\types\help_ca.paa"

// 3DEN stance attribute icons drawn by the stance keybinds
#define STANCE_ICON_UP "\a3\3DEN\Data\Attributes\Stance\up_ca.paa"
#define STANCE_ICON_MIDDLE "\a3\3DEN\Data\Attributes\Stance\middle_ca.paa"
#define STANCE_ICON_DOWN "\a3\3DEN\Data\Attributes\Stance\down_ca.paa"
#define STANCE_ICON_AUTO "\a3\3DEN\Data\Attributes\default_ca.paa"

// ZEN's own Combat Mode context-menu glyph, tinted the same way ZEN tints it
#define ICON_COMBAT_MODE "\x\zen\addons\context_actions\ui\hold_ca.paa"
#define COLOR_HOLD_FIRE [1, 0, 0, 1]
#define COLOR_OPEN_FIRE [1, 1, 1, 1]
