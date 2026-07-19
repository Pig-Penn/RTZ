#define COMPONENT restrict
#define COMPONENT_BEAUTIFIED Restrict
#include "\x\rtz\addons\main\script_mod.hpp"

// #define DEBUG_MODE_FULL
// #define DISABLE_COMPILE_CACHE

#ifdef DEBUG_ENABLED_RESTRICT
    #define DEBUG_MODE_FULL
#endif

#ifdef DEBUG_SETTINGS_RESTRICT
    #define DEBUG_SETTINGS DEBUG_SETTINGS_RESTRICT
#endif

#include "\x\rtz\addons\main\script_macros.hpp"

// Child control IDCs inside a ZEN attribute row group, mirrored from
// ZEN/addons/attributes/script_component.hpp — used to grey out locked rows
#define IDC_ZEN_ATTRIBUTE_LABEL   401
#define IDC_ZEN_ATTRIBUTE_COMBO   403
#define IDC_ZEN_ATTRIBUTE_EDIT    404
#define IDC_ZEN_ATTRIBUTE_SLIDER  405
#define IDC_ZEN_ATTRIBUTE_TOOLBOX 406
#define IDC_ZEN_ATTRIBUTE_MODE    407

// Fade applied to a locked row's input controls — dim enough to read as
// disabled while the value stays legible (sliders double as unit info)
#define FADE_LOCKED 0.4
