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

// This component is shared INFRASTRUCTURE only: selection normalizers, the
// errand engine, and presentation helpers other components call. Features that
// happen to be small do not belong here — the deploy-countermeasures order, the
// curator keybind orders and the spawned-unit skill table all used to live in
// this file's component and are now rtz_smoke, rtz_orders and rtz_skill. Every
// other addon requires rtz_common, so anything parked here is loaded by
// everyone whether they use it or not.

// FUNC(sideColor) palette index for a side with no entry of its own (civilian)
#define SIDE_COLOR_DEFAULT 4

// Default 3D icon drawn at the spot by the placement preview picker, and the
// size it and its hint text are drawn at
#define ICON_PREVIEW "\a3\ui_f\data\igui\cfg\cursors\select_target_ca.paa"
#define PREVIEW_ICON_SIZE 1.2
#define PREVIEW_TEXT_SIZE 0.03

// Icons for the shared context-menu submenu anchors (CfgZenContext.hpp)
#define ICON_SUBMENU_OVERLAYS "\a3\ui_f\data\igui\cfg\simpletasks\types\documents_ca.paa"
#define ICON_SUBMENU_CONTROL "\a3\ui_f\data\igui\cfg\simpletasks\types\help_ca.paa"
