#include "script_component.hpp"
/*
 * Author: Maxim
 * CfgContext modifierFunction for the chevron-display toggle: sets the
 * action's label (index 1) and tint (index 3) to reflect whether individual
 * chevrons are currently shown FOR THIS CLIENT (the state is per-curator, so
 * no broadcast variable is involved).
 *
 * Arguments:
 * 0: Action array, mutated in place <ARRAY>
 *
 * Return Value:
 * None
 *
 * Example:
 * [_action] call rtz_spotting_fnc_chevronsActionModifier
 *
 * Public: No
 */

params ["_action"];

if (GVAR(chevronsEnabled)) then {
    _action set [1, LLSTRING(ActionHideChevrons)];
    _action set [3, [1, 1, 1, 1]];
} else {
    _action set [1, LLSTRING(ActionShowChevrons)]; // On
    _action set [3, [0.5, 0.5, 0.5, 1]]; // Grey
};
