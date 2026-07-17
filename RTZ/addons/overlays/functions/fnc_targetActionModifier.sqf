#include "script_component.hpp"
/*
 * rtz_overlays_fnc_targetActionModifier
 *
 * CfgContext modifierFunction for the target-display toggle (see
 * CfgContext.hpp). Sets the action's label (index 1) and tint (index 3) to
 * reflect whether the overlay master switch is currently on FOR THIS CLIENT
 * (the state is per-curator, so no broadcast variable is involved):
 *   off → white "Draw Targets"
 *   on  → green "Hide Targets"
 *
 * Parameters:
 *   0: Array — the action array (mutated in place)
 */

params ["_action"];

if (GVAR(tgtEnabled)) then {
    _action set [1, LLSTRING(ActionHideTargets)];
    _action set [3, [0.40, 1.00, 0.40, 1]];   // green — currently on, will switch off
} else {
    _action set [1, LLSTRING(ActionDrawTargets)];
    _action set [3, [1, 1, 1, 1]];            // white — will switch on
};
