#include "script_component.hpp"
/*
 * Author: Maxim
 * CfgContext modifierFunction shared by every overlay toggle: sets the action's
 * label and tint to reflect whether that stream is currently on FOR THIS CLIENT
 * (the state is per-curator, so no broadcast variable is involved). A running
 * overlay goes grey "Hide …"; an idle one keeps its own accent colour.
 *
 * The labels are resolved here rather than passed in from CfgContext.hpp: a
 * `localize` inside QUOTE(...) would emit a double-quoted string into the middle
 * of the double-quoted config string the macro builds.
 *
 * Arguments:
 * 0: The action array (mutated in place) <ARRAY>
 * 1: Stream id <STRING>
 *
 * Return Value:
 * None
 *
 * Example:
 * [_action, STREAM_DEST] call rtz_overlays_fnc_overlayActionModifier
 *
 * Public: No
 */

params ["_action", "_stream"];

// [label while OFF, label while ON, tint while OFF]
private _look = switch (_stream) do {
    case STREAM_DEST: {
        [LLSTRING(ActionDrawDestinations), LLSTRING(ActionHideDestinations), COLOR_DEST]
    };
    case STREAM_TGT: {
        [LLSTRING(ActionDrawTargets), LLSTRING(ActionHideTargets), COLOR_TGT]
    };
    default { [] };
};

if (_look isEqualTo []) exitWith {};

_look params ["_labelOff", "_labelOn", "_colorOff"];

if (_stream in GVAR(active)) then {
    _action set [ACTION_INDEX_DISPLAYNAME, _labelOn];
    _action set [ACTION_INDEX_ICONCOLOR, COLOR_OVERLAY_ON];   // grey — running, will hide
} else {
    _action set [ACTION_INDEX_DISPLAYNAME, _labelOff];
    _action set [ACTION_INDEX_ICONCOLOR, _colorOff];
};
