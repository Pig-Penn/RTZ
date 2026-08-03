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
 * [_action, STREAM_DEST] call rtz_hud_fnc_overlayActionModifier
 *
 * Public: No
 */

params ["_action", "_stream"];

// Labels and tint come from the stream's own declaration (FUNC(registerStream)).
// This was a switch over the ids this addon owns, bailing silently on any other —
// which is why rtz_supply carried a near-identical copy of this function purely to
// name its own action. One implementation now serves every registered stream.
private _look = GVAR(streamLook) get _stream;
if (isNil "_look") exitWith {};

_look params ["", "_labels", "_colorOff"];
_labels params ["_labelOff", "_labelOn"];

if (_labelOff isEqualTo "") exitWith {};

if (_stream in GVAR(activeStreams)) then {
    _action set [ACTION_INDEX_DISPLAYNAME, _labelOn];
    _action set [ACTION_INDEX_ICONCOLOR, COLOR_OVERLAY_ON];   // grey — running, will hide
} else {
    _action set [ACTION_INDEX_DISPLAYNAME, _labelOff];
    _action set [ACTION_INDEX_ICONCOLOR, _colorOff];
};
