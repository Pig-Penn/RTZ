#include "script_component.hpp"
/*
 * Author: Maxim
 * Context-menu statement shared by every AI-state overlay: master on/off switch
 * for one stream, PER-CLIENT (each Zeus curates their own).
 *
 * Switching one ON registers its renderer with the shared frame loop and clears
 * the subscription baseline so FUNC(selectionPoll) re-reports on its next tick —
 * with the widened stream list, which is what starts the server feeding it.
 * Switching one OFF unregisters the renderer and drops its snapshot, so a
 * switched-off overlay costs nothing per frame rather than an early exit per
 * frame; with the last one off the hull slice empties and the subscription lapses.
 *
 * Arguments:
 * 0: Stream id <STRING>
 * 1: Report the new state as a toast <BOOL> (default: true)
 *
 * Return Value:
 * None
 *
 * Example:
 * ["dest"] call rtz_core_fnc_toggleOverlay
 *
 * Public: No
 */

params ["_stream", ["_report", true]];

private _index = GVAR(activeStreams) find _stream;
private _on    = _index < 0;

if (_on) then {
    GVAR(activeStreams) pushBack _stream;

    private _draw = GVAR(streamRenderers) get _stream;
    if (!isNil "_draw") then {
        [_stream, _draw, RENDER_WORLD, 20] call FUNC(registerRenderer);
    };
} else {
    GVAR(activeStreams) deleteAt _index;
    GVAR(streamData) deleteAt _stream;
    [_stream, RENDER_WORLD] call FUNC(unregisterRenderer);
};

// Force FUNC(selectionPoll) to re-report on its next tick: the stream list is
// part of the payload it diffs, and with the overlays previously off the hull
// slice was being reported empty.
GVAR(reported) = [];

if (!_report) exitWith {};

// Toast wording comes from the stream's own declaration (FUNC(registerStream)),
// not from a switch over the ids this addon happens to own. That switch fell
// through to ["", ""] for anything else, so rtz_supply had to call this with
// reporting OFF and emit its own toast from a function that existed for no other
// reason. Registered labels mean one shared implementation serves every stream.
private _toasts = (GVAR(streamLook) getOrDefault [_stream, [["", ""]]]) select 0;
private _msg = _toasts select _on;

if (_msg isEqualTo "") exitWith {};

[_msg] call EFUNC(common,showCountMessage);
