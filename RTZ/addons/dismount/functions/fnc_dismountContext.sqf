#include "script_component.hpp"
/*
 * rtz_fnc_dismountContext
 *
 * Registers the "Forbid/Allow Dismount" toggle in the Real-Time Zeus context
 * menu (root-level category RTZ_Control): a single entry at the top of the
 * Control submenu whose label and icon tint track the hovered/selected
 * vehicle's current state via FUNC(dismountActionModifier). Clicking it
 * flips every selected vehicle through FUNC(toggleUnloadInCombat). Static
 * weapons (HMGs, mortars, GMGs) have no dismount concept, so the condition
 * excludes a selection that resolves to nothing but StaticWeapons.
 *
 * Loading: called by FUNC(unloadInCombat) (hasInterface) once the dismount
 * control system is on.
 */

private _action = [
    "RTZ_ToggleDismount",
    "Forbid Dismount",                        // default label/icon; replaced by modifier
    [ICON_LOCKED, COLOR_LOCKED],
    {
        // ZEN passes [_position, _objects, _groups, _waypoints, _markers, _hoveredEntity, _args]
        params ["", "_objects"];
        [_objects] call FUNC(toggleUnloadInCombat);
    },
    {
        params ["", "_objects"];
        (([_objects] call EFUNC(common,collectVehicles)) findIf { !(_x isKindOf "StaticWeapon") }) != -1
    },
    [],                          // args
    {},                          // insertChildren
    FUNC(dismountActionModifier) // modifierFunction
] call zen_context_menu_fnc_createAction;

[_action, ["RTZ_Control"], 0] call zen_context_menu_fnc_addAction;
