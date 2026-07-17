#include "script_component.hpp"
/*
 * rtz_overlays_fnc_destinationActionModifier
 *
 * CfgContext modifierFunction for the destination-display toggle (see
 * CfgContext.hpp). Sets the action's label (index 1) and tint (index 3) to
 * reflect whether the overlay master switch is currently on FOR THIS CLIENT
 * (the state is per-curator, so no broadcast variable is involved):
 *   off → white "Draw Destinations"
 *   on  → white "Hide Destinations"
 *
 * Parameters:
 *   0: Array — the action array (mutated in place)
 */

params ["_action"];

if (GVAR(destEnabled)) then {
    _action set [1, LLSTRING(ActionHideDestinations)];
    _action set [3, [1.00, 1.00, 1.00, 1]];   // white
} else {
    _action set [1, LLSTRING(ActionDrawDestinations)];
    _action set [3, [1, 1, 1, 1]];            // white
};
