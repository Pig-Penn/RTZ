#include "script_component.hpp"
/*
 * rtz_fnc_destinationActionModifier
 *
 * ZEN context-menu modifierFunction for the destination-display toggle. Sets
 * the action's label (index 1) and tint (index 3) to reflect whether the
 * overlay master switch is currently on FOR THIS CLIENT (the state is
 * per-curator, so no broadcast variable is involved):
 *   off → white "Draw Destinations"
 *   on  → white "Hide Destinations"
 *
 * Parameters (passed by ZEN as [_action, ACTION_PARAMS]):
 *   0: Array — the action array (mutated in place)
 *   1: Array — [_position, _objects, _groups, _waypoints, _markers, _hoveredEntity, _args]
 */

params ["_action"];

if (GVAR(destEnabled)) then {
    _action set [1, "Hide Destinations"];
    _action set [3, [1.00, 1.00, 1.00, 1]];   // white
} else {
    _action set [1, "Draw Destinations"];
    _action set [3, [1, 1, 1, 1]];            // white
};
