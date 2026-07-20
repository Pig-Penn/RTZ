#define COMPONENT unit_info
#define COMPONENT_BEAUTIFIED Unit Info
#include "\x\rtz\addons\main\script_mod.hpp"

// #define DEBUG_MODE_FULL
// #define DISABLE_COMPILE_CACHE

#ifdef DEBUG_ENABLED_UNIT_INFO
    #define DEBUG_MODE_FULL
#endif

#ifdef DEBUG_SETTINGS_UNIT_INFO
    #define DEBUG_SETTINGS DEBUG_SETTINGS_UNIT_INFO
#endif

#include "\x\rtz\addons\main\script_macros.hpp"

// Health bar dimensions in drawIcon3D units, multiplied by the scale setting
#define BAR_WIDTH 2
#define BAR_HEIGHT 0.2
#define BAR_TEXTURE "#(argb,8,8,3)color(1,1,1,1)"
#define BAR_ALPHA 0.9

// Ammo bar below the health bar (offset is in screen space, positive is down)
#define AMMO_BAR_HEIGHT 0.12
#define AMMO_OFFSET_Y 0.012
#define COLOR_AMMO [0.3, 0.62, 1, BAR_ALPHA]

// Info text (offset is in screen space, negative is up)
#define TEXT_SIZE 0.03
#define TEXT_FONT "RobotoCondensedBold"
#define TEXT_OFFSET_Y -0.02
#define TEXT_SEPARATOR " | "

// Colors
#define COLOR_BACKGROUND [0, 0, 0, 0.5]
#define COLOR_TEXT_DEFAULT [1, 1, 1, 1]
#define COLOR_TEXT_DEAD [0.85, 0.16, 0.16, 1]
#define COLOR_TEXT_UNCONSCIOUS [1, 0.72, 0.16, 1]
#define COLOR_BAR_UNCONSCIOUS [1, 0.72, 0.16, BAR_ALPHA]

// Height above the unit's bounding box at which the info is drawn
#define HEIGHT_OFFSET 0.4
