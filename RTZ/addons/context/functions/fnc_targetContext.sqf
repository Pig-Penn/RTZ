#include "script_component.hpp"
/*
 * rtz_fnc_targetContext
 *
 * Registers the "Draw Targets" toggle in the Real-Time Zeus context menu
 * (root-level category RTZ_Overlays). The action is a master switch: while ON, the
 * overlay follows the curator's live selection (FUNC(targetDisplay) draws
 * engagement targets for whatever is selected, dropping them on deselect), so
 * the entry is always offered regardless of the current selection. Label/tint
 * track the switch state via FUNC(targetActionModifier).
 *
 * Loading: called by XEH_postInit (hasInterface) when the target-display system is on.
 */

private _action = [
    "RTZ_ToggleTargets",
    "Draw Targets",                                                                // default; modifier overrides
    ["\x\zen\addons\modules\ui\target_ca.paa", [1, 1, 1, 1]],
    { [] call FUNC(targetToggle) },
    { true },                           // master switch — selection is read live
    [],                                 // args
    {},                                 // insertChildren
    FUNC(targetActionModifier)          // modifierFunction — live label/tint
] call zen_context_menu_fnc_createAction;

[_action, ["RTZ_Overlays"], 3] call zen_context_menu_fnc_addAction;
