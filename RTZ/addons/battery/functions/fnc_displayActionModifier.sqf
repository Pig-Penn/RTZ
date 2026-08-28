#include "script_component.hpp"
/*
 * Author: Maxim
 * CfgContext modifierFunction for the counter-battery overlay toggle: sets the
 * action's label and tint to reflect whether contacts are currently shown FOR THIS
 * CLIENT (the state is per-curator, so no broadcast variable is involved).
 *
 * Note that ZEN runs modifierFunction BEFORE condition
 * (zen_context_menu_fnc_getActiveActions), so this reads GVAR(visible) even with
 * the system disabled — which is why XEH_preInit creates it unconditionally rather
 * than leaving it to the settings-gated FUNC(startSystem).
 *
 * Slots are addressed through SET_ACTION / the ACTION_INDEX_* macros in
 * main/script_curator.hpp, as every other action modifier in the mod does.
 *
 * Arguments:
 * 0: Action array, mutated in place <ARRAY>
 *
 * Return Value:
 * None
 *
 * Example:
 * [_action] call rtz_battery_fnc_displayActionModifier
 *
 * Public: No
 */

params ["_action"];

if (GVAR(visible)) then {
    SET_ACTION(_action,LLSTRING(ActionHideContacts),ICON_TOGGLE,COLOR_ACTION_ON);
} else {
    SET_ACTION(_action,LLSTRING(ActionShowContacts),ICON_TOGGLE,COLOR_ACTION_OFF);
};
