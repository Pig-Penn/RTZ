#define COMPONENT vehicle_info
#define COMPONENT_BEAUTIFIED Vehicle Info
#include "\x\rtz\addons\main\script_mod.hpp"

// #define DEBUG_MODE_FULL
// #define DISABLE_COMPILE_CACHE

#ifdef DEBUG_ENABLED_VEHICLE_INFO
    #define DEBUG_MODE_FULL
#endif

#ifdef DEBUG_SETTINGS_VEHICLE_INFO
    #define DEBUG_SETTINGS DEBUG_SETTINGS_VEHICLE_INFO
#endif

#include "\x\rtz\addons\main\script_macros.hpp"

// Health bar dimensions in drawIcon3D units, multiplied by the scale setting
#define BAR_WIDTH 3
#define BAR_HEIGHT 0.2
#define BAR_TEXTURE "#(argb,8,8,3)color(1,1,1,1)"
#define BAR_ALPHA 0.9

// Fuel and ammo bars stack below the health bar (offset is in screen space, positive is down)
#define SUB_BAR_HEIGHT 0.12
#define SUB_BAR_OFFSET_Y 0.012
#define COLOR_FUEL [1, 0.65, 0.15, BAR_ALPHA]
#define COLOR_AMMO [0.3, 0.62, 1, BAR_ALPHA]

// Info text (offset is in screen space, negative is up)
#define TEXT_SIZE 0.03
#define TEXT_FONT "RobotoCondensedBold"
#define TEXT_OFFSET_Y -0.02
#define TEXT_SEPARATOR " | "

// Damage tag line drawn below the last bar
#define DAMAGE_TAG_THRESHOLD 0.65
#define DAMAGE_OFFSET_EXTRA_Y 0.016

// Colors
#define COLOR_BACKGROUND [0, 0, 0, 0.5]
#define COLOR_TEXT_DEFAULT [1, 1, 1, 1]
#define COLOR_TEXT_DESTROYED [0.85, 0.16, 0.16, 1]
#define COLOR_TEXT_DAMAGE [0.85, 0.16, 0.16, 1]

// Height above the vehicle's bounding box at which the info is drawn
#define HEIGHT_OFFSET 0.5
