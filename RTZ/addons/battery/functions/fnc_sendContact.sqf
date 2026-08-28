#include "script_component.hpp"
/*
 * Author: Maxim
 * Builds one track's packet and targets it at every hostile curator. Called two
 * ways: directly by FUNC(dispatchContact) when a round is due to go out
 * immediately, and as the body of the deferred flush that a round arriving inside
 * SEND_INTERVAL arms instead.
 *
 * _watchers may arrive already resolved — the cold path in FUNC(dispatchContact)
 * has to resolve them anyway to decide whether the track is worth creating, so
 * handing the list over rather than walking allCurators twice for one shot is free.
 * An empty list means "resolve them now", which is what the deferred path wants: up
 * to a second has passed, and a curator can have connected, left or changed side in
 * it.
 *
 * A deferred call crosses a suspension, so everything it reads is re-validated
 * here rather than captured at arm time (Gotchas §1) — the registry may have
 * dropped the track to its cap, or the whole system may have been switched off.
 *
 * Arguments:
 * 0: Track key (the firing gun's netId) <STRING>
 * 1: Pre-resolved hostile curator players, [] to resolve here <ARRAY> (default: [])
 *
 * Return Value:
 * None
 *
 * Example:
 * [_gunId, []] call rtz_battery_fnc_sendContact
 *
 * Public: No
 */

params ["_gunId", ["_watchers", []]];

if (!GVAR(enabled)) exitWith {};

private _track = GVAR(tracks) get _gunId;
if (isNil "_track") exitWith {};

_track params ["_trackId", "_name", "_offset", "_incOffset", "_gunPos", "_aimPos",
               "_firstTime", "_lastTime", "_rounds", "", "", "_splashTime", "_firerSide"];

// Stamped and cleared before the early-out below, not after it: a flush that finds
// nobody watching has still consumed its timer, and leaving the pending flag set
// would mean no later round from this gun ever arms another one.
_track set [9, CBA_missionTime];
_track set [10, false];

if (_watchers isEqualTo []) then {
    _watchers = [_firerSide] call FUNC(hostileCurators);
};

if (_watchers isEqualTo []) exitWith {};

// The offset is applied to the gun's LIVE position, so the true gun stays inside
// the drawn circle rather than merely near it — see FUNC(dispatchContact). Built by
// index rather than vectorAdd so a 2-element position cannot produce a silently
// empty result: [] vectorAdd [...] stays [] and draws nothing, with no error to say
// why (Gotchas §3). Z is dropped outright — every consumer is a map draw.
private _centre = [(_gunPos # 0) + (_offset # 0), (_gunPos # 1) + (_offset # 1), 0];

private _incCentre = [];
if (count _aimPos > 1) then {
    _incCentre = [(_aimPos # 0) + (_incOffset # 0), (_aimPos # 1) + (_incOffset # 1), 0];
};

// Absolute times, never ages — the docs/Architecture.md gatherer rule. An age would
// have to be re-sent to stay true; a frozen timestamp is aged client-side every
// frame, which also makes the readout climb smoothly between packets rather than
// stepping once a second.
//
// Note what is NOT in here: the gun, its netId, and its real position. The client
// store is keyed on _trackId precisely so that a client holding this packet has no
// route back to the object.
private _payload = [_trackId, _centre, GVAR(originRadius), _firstTime, _lastTime,
                    _rounds, _name, _incCentre, GVAR(incomingRadius), _splashTime];

{
    [QGVAR(contact), _payload, _x] call CBA_fnc_targetEvent;
} forEach _watchers;
