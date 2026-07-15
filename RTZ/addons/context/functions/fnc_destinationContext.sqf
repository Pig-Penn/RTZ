#include "script_component.hpp"
/*
 * rtz_fnc_destinationContext
 *
 * Registers the "Draw Destinations" toggle in the Real-Time Zeus context menu
 * (root-level category RTZ_Overlays). The action is a master switch: while ON, the
 * overlay follows the curator's live selection (FUNC(destinationDisplay) draws
 * destinations for whatever is selected, dropping them on deselect), so the
 * entry is always offered regardless of the current selection. Label/tint
 * track the switch state via FUNC(destinationActionModifier).
 *
 * Loading: called by XEH_postInit (hasInterface) when the destination-display system is on.
 */

private _action = [
    "RTZ_ToggleDestinations",
    "Draw Destinations",                                                           // default; modifier overrides
    ["\a3\ui_f\data\igui\cfg\simpletasks\types\move_ca.paa", [1, 1, 1, 1]],
    { [] call FUNC(destinationToggle) },
    { true },                           // master switch — selection is read live
    [],                                 // args
    {},                                 // insertChildren
    FUNC(destinationActionModifier)     // modifierFunction — live label/tint
] call zen_context_menu_fnc_createAction;

[_action, ["RTZ_Overlays"], 3] call zen_context_menu_fnc_addAction;
