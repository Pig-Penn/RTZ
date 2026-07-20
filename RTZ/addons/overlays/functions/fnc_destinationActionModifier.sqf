#include "script_component.hpp"
/*
 * Author: Maxim
 * CfgContext modifierFunction for the destination-display toggle: sets the
 * action's label (index 1) and tint (index 3) to reflect whether the overlay
 * master switch is currently on FOR THIS CLIENT (the state is per-curator,
 * so no broadcast variable is involved).
 *
 * Arguments:
 * 0: Action array, mutated in place <ARRAY>
 *
 * Return Value:
 * None
 *
 * Example:
 * [_action] call rtz_overlays_fnc_destinationActionModifier
 *
 * Public: No
 */

params ["_action"];

if (GVAR(destEnabled)) then {
    _action set [1, LLSTRING(ActionHideDestinations)]; // Off
    _action set [3, [0.50, 0.50, 0.50, 1]]; // Grey
} else {
    _action set [1, LLSTRING(ActionDrawDestinations)]; // On
    _action set [3, [1.00, 0.80, 0.40, 1]]; // Gold
};
