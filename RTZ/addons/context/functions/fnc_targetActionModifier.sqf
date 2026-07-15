#include "script_component.hpp"
/*
 * rtz_fnc_targetActionModifier
 *
 * ZEN context-menu modifierFunction for the target-display toggle. Sets the
 * action's label (index 1) and tint (index 3) to reflect whether the overlay
 * master switch is currently on FOR THIS CLIENT (the state is per-curator, so
 * no broadcast variable is involved):
 *   off → white "Draw Targets"
 *   on  → green "Hide Targets"
 *
 * Parameters (passed by ZEN as [_action, ACTION_PARAMS]):
 *   0: Array — the action array (mutated in place)
 *   1: Array — [_position, _objects, _groups, _waypoints, _markers, _hoveredEntity, _args]
 */

params ["_action"];

if (GVAR(tgtEnabled)) then {
    _action set [1, "Hide Targets"];
    _action set [3, [0.40, 1.00, 0.40, 1]];   // green — currently on, will switch off
} else {
    _action set [1, "Draw Targets"];
    _action set [3, [1, 1, 1, 1]];            // white — will switch on
};
