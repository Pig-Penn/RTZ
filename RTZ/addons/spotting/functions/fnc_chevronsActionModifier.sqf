#include "script_component.hpp"
/*
 * Author: Maxim
 * CfgContext modifierFunction for the chevron-display toggle: sets the
 * action's label and tint to reflect whether individual chevrons are currently
 * shown FOR THIS CLIENT (the state is per-curator, so no broadcast variable is
 * involved).
 *
 * Slots addressed through the ACTION_INDEX_* macros in main/script_macros.hpp,
 * as every other action modifier in the mod does. They were spelled here as bare
 * 1 and 3 — the only two magic indices left into ZEN's action array, and the one
 * place a slot reshuffle would have gone unnoticed.
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
    _action set [ACTION_INDEX_DISPLAYNAME, LLSTRING(ActionHideChevrons)];
    _action set [ACTION_INDEX_ICONCOLOR, [1, 1, 1, 1]];             // white — showing, will hide
} else {
    _action set [ACTION_INDEX_DISPLAYNAME, LLSTRING(ActionShowChevrons)];
    _action set [ACTION_INDEX_ICONCOLOR, [0.5, 0.5, 0.5, 1]];       // grey — hidden, will show
};
