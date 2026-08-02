#include "script_component.hpp"
/*
 * Author: Maxim
 * CfgContext modifierFunction for the supply-lines toggle: sets the action's
 * label and tint to reflect whether the overlay is currently on FOR THIS CLIENT
 * (the state is per-curator, so no broadcast variable is involved). A running
 * overlay goes grey "Hide …"; an idle one keeps the supply accent colour.
 *
 * The engine's own EFUNC(hud,overlayActionModifier) resolves its wording
 * from a switch over the stream ids it knows about and bails out silently on any
 * other, so a stream registered from outside that addon brings its own — see
 * FUNC(toggleSupplyOverlay) for the matching half.
 *
 * The labels are resolved here rather than passed in from CfgContext.hpp: a
 * `localize` inside QUOTE(...) would emit a double-quoted string into the middle
 * of the double-quoted config string the macro builds.
 *
 * Arguments:
 * 0: The action array (mutated in place) <ARRAY>
 *
 * Return Value:
 * None
 *
 * Example:
 * [_action] call rtz_supply_fnc_supplyOverlayModifier
 *
 * Public: No
 */

params ["_action"];

if (STREAM_SUPPLY in EGVAR(hud,activeStreams)) then {
    _action set [ACTION_INDEX_DISPLAYNAME, LLSTRING(ActionHideSupplyLines)];
    _action set [ACTION_INDEX_ICONCOLOR, COLOR_OVERLAY_ON];   // grey — running, will hide
} else {
    _action set [ACTION_INDEX_DISPLAYNAME, LLSTRING(ActionDrawSupplyLines)];
    _action set [ACTION_INDEX_ICONCOLOR, COLOR_SUPPLY];
};
