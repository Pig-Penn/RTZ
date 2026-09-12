#include "script_component.hpp"
/*
 * Author: Maxim
 * Server-side coalescing gate. Answers "is this the first event for this key inside
 * the current window", and stamps the key when it is.
 *
 * Both report halves fan out through a curatorEditableObjects walk per curator,
 * which is by far the expensive part of either path, and both get bursts that say
 * nothing after the first: a launcher salvo at one vehicle, a ZEN throw order that
 * puts one grenade per man onto one aim point. This gate is what keeps a burst to
 * one fan-out. The two halves shipped as verbatim copies of each other.
 *
 * The key TYPE is the caller's business — FUNC(reportIncoming) keys on the target's
 * netId, FUNC(reportGrenade) on a quantized aim point as a two-element ARRAY — and the
 * two keep separate maps precisely so those key spaces can never collide.
 *
 * Array keys are deep-copied on insertion and must not be mutated once read back, so
 * both bounding stages below only ever hand a key to `deleteAt`.
 *
 * Arguments:
 * 0: Window map <HASHMAP> — key -> absolute expiry, bounded in place
 * 1: Key <STRING, NUMBER or ARRAY>
 * 2: Window length in seconds <NUMBER>
 * 3: Current time, CBA_missionTime <NUMBER>
 *
 * Return Value:
 * Claimed — true when the caller should proceed, false when a live window already
 * covers this key <BOOL>
 *
 * Example:
 * [GVAR(recent), netId _target, RECENT_WINDOW, CBA_missionTime] call rtz_missile_fnc_claimWindow
 *
 * Public: No
 */

params ["_window", "_key", "_length", "_now"];

// A literal 0 as the default is free to evaluate eagerly; the getOrDefault caveat
// only bites when the default is an expression.
if ((_window getOrDefault [_key, 0]) > _now) exitWith {false};

_window set [_key, _now + _length];

// Two-stage bound, entered only while over the cap — and one insert can only push it
// one over, so this is one walk per insert at worst and none at all in the normal
// case. Expired entries first, which clears the map in every realistic case, then a
// whole flush behind it so it can never grow past the cap even if every entry is
// somehow still live.
//
// Both stages delete IN PLACE rather than rebinding _window, because this function
// holds only a REFERENCE to the caller's global (Gotchas §3).
if (count _window > RECENT_CAP) then {
    private _dead = [];

    {
        if (_y <= _now) then {
            _dead pushBack _x;
        };
    } forEach _window;

    {
        _window deleteAt _x;
    } forEach _dead;

    // `keys` hands back a fresh array, so deleting while walking it is safe.
    if (count _window > RECENT_CAP) then {
        {_window deleteAt _x} forEach keys _window;
    };
};

true
