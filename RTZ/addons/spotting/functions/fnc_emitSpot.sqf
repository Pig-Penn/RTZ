#include "script_component.hpp"
/*
 * Author: Maxim
 * Send/refresh one spot to its spotter Zeus. The client samples icon position
 * live every frame, so position never needs re-sending. spotDetected is sent
 * only when the payload signature changed, when the RECIPIENT changed, or when
 * _force is set.
 *
 * The signature describes the payload only — it deliberately does NOT carry the
 * destination player's netId. It used to, purely so that a curator module handed
 * to a DIFFERENT player would re-send; that made every caller concatenate the
 * player id onto every signature, per icon, per curator, per tick. The recipient
 * change is now detected directly below, which is both cheaper and more honest
 * about what a "signature" means.
 *
 * A rejoin into the SAME slot is not covered by either mechanism: Arma returns
 * the same unit object to the returning player, so the recipient compares equal
 * and the payload is unchanged. That case is recovered solely by the client's
 * QGVAR(spotResync) request (see FUNC(spottingClient)), which the server holds
 * per-player until that player resolves to a curator and then feeds back in here
 * as _force.
 *
 * _draw = false records the contact for new-contact detection, report dedupe
 * and cleanup, but draws no icon (used for lone units that don't warrant a
 * group marker); if the contact previously had an icon it is removed, so a
 * squad worn down to a single survivor loses its group marker cleanly.
 *
 * The signature is an ARRAY built by FUNC(spotCheck) and compared here with
 * isEqualTo. It must be isEqualTo and cannot be ==/!=: SQF's equality operators
 * reject arrays outright rather than comparing them, so the obvious spelling is a
 * runtime error, not a slow path. The stored-off sentinel SPOT_SIG_OFF is a STRING,
 * which the same comparison handles correctly — isEqualTo answers `false` across
 * mismatched types instead of throwing (Gotchas §3), and an off sentinel is never
 * equal to a live signature.
 *
 * Arguments:
 * 0: Spot key <STRING>
 * 1: spotDetected event payload (payload select 0 = marker name) <ARRAY>
 * 2: Payload signature <ARRAY>
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
    // Hand-over: this key's previous recipient is not the current destination, i.e.
    // the curator module changed hands (the key is per curator MODULE, not per
    // player).
    //
    // Tested here as a flag rather than by embedding the destination's netId in
    // the signature string. It used to be embedded, which meant every caller
    // concatenated the player id onto every signature for every icon for every
    // curator, every tick — on a busy side that is hundreds of throwaway string
    // allocations a tick to express a condition this branch already computes.
    // Same semantics: a changed recipient forces the send below.
    private _newRecipient = !_isNew && { (_prev select 1) != _player };

    // The OLD recipient would otherwise keep the icon in its store for the rest of
    // the mission, and render it as its own the moment it is made a curator again.
    // isPlayer, not isNull, for the departed-player-body reason described below.
    if (_newRecipient && { isPlayer (_prev select 1) }) then {
        [QGVAR(spotLost), [_prev select 0], _prev select 1] call CBA_fnc_targetEvent;
    };

    if (_force || { _isNew } || { _newRecipient } || { (_prev select 2) isNotEqualTo _sig }) then {
        [QGVAR(spotDetected), _payload, _player] call CBA_fnc_targetEvent;
    };

    _activeSpots set [_key, [_mrkr, _player, _sig]];
} else {
    // Drop a previously drawn icon when this contact stops qualifying to draw.
    // Target the player who originally received spotDetected (_prev select 1),
    // not necessarily the current _player — they must match for the client to clear it.
    // That stored player may have disconnected since. isPlayer, not isNull: both a
    // null object AND a departed player's leftover AI body resolve to owner 2, so an
    // unguarded targetEvent misfires to the server — harmless on a dedicated server,
    // but a listen-server host has the receivers and would render the retraction (and,
    // via the _draw branch above, the spots themselves) as its own. See the
    // curator-resolution block in FUNC(spotCheck).
    if (!_isNew && { (_prev select 2) isNotEqualTo SPOT_SIG_OFF } && { isPlayer (_prev select 1) }) then {
        [QGVAR(spotLost), [_prev select 0], _prev select 1] call CBA_fnc_targetEvent;
    };

    _activeSpots set [_key, [_mrkr, _player, SPOT_SIG_OFF]];
};
