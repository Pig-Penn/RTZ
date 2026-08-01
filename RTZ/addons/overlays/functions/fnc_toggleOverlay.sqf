#include "script_component.hpp"
/*
 * Author: Maxim
 * Context-menu statement shared by every overlay: master on/off switch for one
 * stream, PER-CLIENT (each Zeus curates their own). While ON, the Draw3D
 * handler in FUNC(streamClient) follows this curator's live selection and
 * subscribes it to the server poll via QGVAR(watch).
 *
 * Arguments:
 * 0: Stream id <STRING>
 * 1: Report the new state as a toast <BOOL> (default: true)
 *
 * Return Value:
 * None
 *
 * Example:
 * [STREAM_DEST] call rtz_overlays_fnc_toggleOverlay
 *
 * Public: No
 */

params ["_stream", ["_report", true]];

private _index = GVAR(active) find _stream;
private _on    = _index < 0;

if (_on) then {
    GVAR(active) pushBack _stream;
    // Nothing else to do: the sentinel below makes the Draw3D selection sync
    // see the cached selection differ from the live one, so it resolves the
    // selection and subscribes — with the new stream list — next frame.
    GVAR(selection) = [false];
} else {
    GVAR(active) deleteAt _index;
    GVAR(data) deleteAt _stream;

    if (GVAR(active) isEqualTo []) then {
        // Last stream off — unsubscribe entirely and forget the selection, so
        // switching one back on resyncs from scratch.
        GVAR(selection) = [];
        GVAR(watched)   = [];
        [QGVAR(watch), [player, [], []]] call CBA_fnc_serverEvent;
    } else {
        // Others still running: keep the subscription, narrow the stream list.
        [QGVAR(watch), [player, GVAR(watched), GVAR(active)]] call CBA_fnc_serverEvent;
    };
};

if (!_report) exitWith {};

private _msgs = switch (_stream) do {
    case STREAM_DEST: {[LLSTRING(MsgDestinationsHidden), LLSTRING(MsgDestinationsShown)]};
    case STREAM_TGT:  {[LLSTRING(MsgTargetsHidden), LLSTRING(MsgTargetsShown)]};
    default {["", ""]};
};

[_msgs select _on] call EFUNC(common,showCountMessage);
