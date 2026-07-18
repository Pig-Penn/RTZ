#include "script_component.hpp"
/*
 * Author: Maxim
 * Send/refresh one spot to its spotter Zeus. The client samples icon position
 * live every frame, so position never needs re-sending. spotDetected is sent
 * only when the payload signature changed (or _force is set). The signature
 * embeds the destination player's netId, so a rejoined player — a new player
 * object — changes every one of that curator's signatures and triggers a
 * one-shot full re-send automatically.
 *
 * _draw = false records the contact for new-contact detection, report dedupe
 * and cleanup, but draws no icon (used for lone units that don't warrant a
 * group marker); if the contact previously had an icon it is removed, so a
 * squad worn down to a single survivor loses its group marker cleanly.
 *
 * Arguments:
 * 0: Spot key <STRING>
 * 1: spotDetected event payload (payload select 0 = marker name) <ARRAY>
 * 2: Payload signature <STRING>
 * 3: Destination curator player <OBJECT>
 * 4: Active-spots map, spotKey → [markerName, spotterPlayer, sig] — mutated <HASHMAP>
 * 5: Draw an icon for this contact <BOOL>
 * 6: Force re-send even when the signature is unchanged <BOOL>
 *
 * Return Value:
 * None
 *
 * Example:
 * [_key, _payload, _sig, _player, _activeSpots, true, false] call rtz_spotting_fnc_emitSpot
 *
 * Public: No
 */

params ["_key", "_payload", "_sig", "_player", "_activeSpots", "_draw", "_force"];

private _prev   = _activeSpots getOrDefault [_key, []];
private _isNew  = _prev isEqualTo [];
private _mrkr   = _payload select 0;

if (_draw) then {
    if (_force || { _isNew } || { (_prev select 2) != _sig }) then {
        [QGVAR(spotDetected), _payload, _player] call CBA_fnc_targetEvent;
    };
    _activeSpots set [_key, [_mrkr, _player, _sig]];
} else {
    // Drop a previously drawn icon when this contact stops qualifying to draw.
    // Target the player who originally received spotDetected (_prev select 1),
    // not necessarily the current _player — they must match for the client to clear it.
    if (!_isNew && { (_prev select 2) != "_off_" }) then {
        [QGVAR(spotLost), [_prev select 0], _prev select 1] call CBA_fnc_targetEvent;
    };
    _activeSpots set [_key, [_mrkr, _player, "_off_"]];
};
