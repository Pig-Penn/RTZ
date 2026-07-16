#include "script_component.hpp"
/*
 * rtz_fnc_squadHideContext
 *
 * Registers the "Hide Squad (Freeze)" toggle in the Real-Time Zeus context menu
 * (root-level category RTZ_Control). The entry only shows when the selection or
 * hovered entity resolves to at least one group; its label/tint track the first
 * group's current state via FUNC(squadHideActionModifier). Clicking it flips
 * every selected group through FUNC(squadHideToggle), which disables simulation
 * and hides the model of every unit in those groups.
 *
 * Loading: called by XEH_postInit (hasInterface) when the squad-hide system is on.
 */

private _action = [
    "RTZ_ToggleSquadHide",
    "Disable Simulation",                                                               // default; modifier overrides
    ["\x\rtz\addons\context\ui\pause_ca.paa", [1.00, 0.60, 0.20, 1]],
    {
        // ZEN passes [_position, _objects, _groups, _waypoints, _markers, _hoveredEntity, _args]
        params ["", "_objects", "", "", "", "_hoveredEntity"];
        [_objects + [_hoveredEntity]] call FUNC(squadHideToggle);
    },
    {
        params ["", "_objects", "", "", "", "_hoveredEntity"];
        ([_objects + [_hoveredEntity]] call EFUNC(common,collectSquads)) isNotEqualTo []
    },
    [],                             // args
    {},                             // insertChildren
    FUNC(squadHideActionModifier)   // modifierFunction — live label/tint
] call zen_context_menu_fnc_createAction;

[_action, ["RTZ_Control"], 2] call zen_context_menu_fnc_addAction;
