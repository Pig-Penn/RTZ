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

// Keys a locked value box still lets through, from A3's defineDIKCodes.inc —
// declared here rather than included, as RTZ vendors no A3 headers
#define DIK_ESCAPE 0x01
#define DIK_TAB    0x0F

// ZEN internals this component reads or hooks, mirrored from
// ZEN/addons/attributes. Kept in one place so a rename on ZEN's side is a
// single-line fix here rather than a hunt through the functions.
#define ZEN_DISPLAY_REGISTRY "zen_attributes_displays"
#define ZEN_VAR_CONTROLS     "zen_attributes_controls"
#define ZEN_VAR_VALUE        "zen_attributes_value"
#define ZEN_VAR_ON_CONFIRM   "zen_attributes_fnc_onConfirm"

// Child control IDCs inside a ZEN attribute row group, mirrored from
// ZEN/addons/attributes/script_component.hpp — used to grey out locked rows
#define IDC_ZEN_ATTRIBUTE_LABEL   401
#define IDC_ZEN_ATTRIBUTE_COMBO   403
#define IDC_ZEN_ATTRIBUTE_EDIT    404
#define IDC_ZEN_ATTRIBUTE_SLIDER  405
#define IDC_ZEN_ATTRIBUTE_TOOLBOX 406
#define IDC_ZEN_ATTRIBUTE_MODE    407

// Which set of entities a gated row actually writes to. ZEN's servicing
// statements ignore the row's own entity and apply to the curator selection, so
// a row is gated against exactly the set it will touch and nothing more — a
// squad and an out-of-zone truck in the same selection do not block each other.
// Values double as indices into FUNC(canEdit)'s cache, so keep them 0..N-1.
#define SCOPE_OBJECTS     0  // SELECTED_OBJECTS          — Health
#define SCOPE_UNITS       1  // getSelectedUnits (crew)   — Skill, Skills display
#define SCOPE_VEHICLES    2  // getSelectedVehicles       — Fuel, Ammo, cargo, Damage
#define SCOPE_GROUP_UNITS 3  // units of SELECTED_GROUPS  — Group skill
#define SCOPE_COUNT       4

// Fade applied to a locked row's input controls — dim enough to read as
// disabled while the value stays legible (sliders double as unit info)
#define FADE_LOCKED 0.4
