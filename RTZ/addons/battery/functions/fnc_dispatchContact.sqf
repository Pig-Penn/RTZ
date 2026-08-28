#include "script_component.hpp"
/*
 * Author: Maxim
 * Server half: folds one reported shot into the track registry and decides when it
 * goes out. Receiver for QGVAR(shotReported), which FUNC(detectShot) raises from
 * whichever machine owns the firing gun.
 *
 * A "track" is one GUN, not one shot. Everything invariant for its life is resolved
 * once, when it is created, and reused for every later round:
 *
 *   - the OFFSET VECTOR, which is what turns the true position into a zone. Reusing
 *     it is not an optimisation first and foremost — it is what makes the circle sit
 *     still through a fire mission. A fresh roll per round would jitter it once a
 *     second and quietly average out to the gun's real position for anyone watching.
 *   - the gun's DISPLAY NAME, off the repeat path entirely.
 *   - the INCOMING offset, rolled against the aim point on the same rule, so a
 *     ten-round mission at one aim point paints one steady warning ring, not ten.
 *
 * A track is re-rolled — a genuinely new acquisition — when the gun displaces
 * further than the origin radius (the old circle no longer contains it) or when it
 * has aged past its lifetime (the previous fix has expired on every client, so the
 * next fire mission deserves an independent one rather than the stale offset).
 * Between re-rolls the offset is applied to the gun's LIVE position rather than the
 * one it was rolled against, which is what keeps the promise the feature makes: the
 * true gun is always inside the drawn circle, never merely near it.
 *
 * The TRUE GUN POSITION NEVER LEAVES THIS MACHINE. Only the displaced centre is
 * sent, and the client store is keyed on GVAR(nextTrackId) rather than the gun's
 * netId — a netId would let a client objectFromNetId straight back to the gun and
 * read its real position, which is the whole thing the offset exists to hide.
 *
 * Arguments:
 * 0: Firing vehicle <OBJECT>
 * 1: True firing position <ARRAY>
 * 2: Firer's side <SIDE>
 * 3: Predicted impact position, [] when the engine gave none <ARRAY>
 * 4: Estimated time of flight <NUMBER>
 *
 * Return Value:
 * None
 *
 * Example:
 * [_vehicle, getPos _vehicle, east, _aimPos, 22] call rtz_battery_fnc_dispatchContact
 *
 * Public: No
 */

params ["_vehicle", "_gunPos", "_firerSide", "_aimPos", "_tof"];

if (!GVAR(enabled)) exitWith {};
if (isNull _vehicle) exitWith {};

private _now       = CBA_missionTime;
private _gunId     = netId _vehicle;         // an Object is not a legal HashMap key (Gotchas §3)
private _radius    = GVAR(originRadius);
private _incRadius = GVAR(incomingRadius);
private _lifetime  = GVAR(contactLifetime);

// FUNC(detectShot) normalises an unusable aim point to []; distance2D against one
// is a Generic error, so every read of slot 5 is gated on this rather than on the
// value looking plausible (Gotchas §3).
private _hasAim = count _aimPos > 1;

// Track record:
//  0 trackId | 1 name | 2 offsetVec | 3 incOffsetVec | 4 gunPos | 5 aimPos
//  6 firstTime | 7 lastTime | 8 rounds | 9 lastSent | 10 flushPending
//  11 splashTime | 12 firerSide
private _track = GVAR(tracks) get _gunId;

// isNil first, and every later test braced — a plain Boolean on the right of ||
// is evaluated regardless of the left, so an unbraced `_track # 7` here would read
// index 7 of nil on the very first round from every gun (Gotchas §2).
private _cold = isNil "_track"
    || { _now - (_track # 7) > _lifetime }
    || { _gunPos distance2D (_track # 4) > _radius };

// Resolved before any state is written, so a shot nobody hostile can see leaves
// nothing behind. Empty on the hot path, where FUNC(sendContact) resolves it at
// flush time instead — which is also what lets a curator who connects mid-mission
// start receiving from the next flush rather than the next gun.
private _watchers = [];
if (_cold) then {
    _watchers = [_firerSide] call FUNC(hostileCurators);
};

if (_cold && {_watchers isEqualTo []}) exitWith {};

// Uniform over the DISC, not uniform in radius. `random _radius` for the distance
// would put half of every offset inside 0.5r, clustering the fuzz at the centre and
// making the circle a much better fix than its radius claims — a curator would
// learn to search the middle first and usually be right. sqrt(random 1) is the
// standard area correction, and both rolls below use it.
private _bearing = random 360;
private _dist    = sqrt (random 1) * _radius;

private _incBearing = random 360;
private _incDist    = sqrt (random 1) * _incRadius;

if (_cold) then {
    private _trackId = GVAR(nextTrackId);
    GVAR(nextTrackId) = _trackId + 1;

    _track = [
        _trackId,
        ([_vehicle] call EFUNC(common,classInfo)) # 0,
        [(sin _bearing) * _dist, (cos _bearing) * _dist, 0],
        [(sin _incBearing) * _incDist, (cos _incBearing) * _incDist, 0],
        _gunPos,
        _aimPos,
        _now, _now, 1,
        -1e11,      // lastSent: never — forces the immediate send below
        false,
        _now + _tof,
        _firerSide
    ];
    GVAR(tracks) set [_gunId, _track];
} else {
    // Hot path: the same gun firing again. Both offsets are kept; only the counters
    // and the positions they are applied to move.
    _track set [4, _gunPos];
    _track set [7, _now];
    _track set [8, (_track # 8) + 1];
    _track set [11, _now + _tof];

    // The aim point is allowed to walk within the incoming radius without a
    // re-roll — a battery adjusting fire fifty metres should not make the warning
    // ring jump. A genuinely new aim point, or the first usable one this track has
    // seen, gets a new roll.
    private _aimMoved = _hasAim
        && {(count (_track # 5)) < 2 || {_aimPos distance2D (_track # 5) > _incRadius}};

    if (_aimMoved) then {
        _track set [3, [(sin _incBearing) * _incDist, (cos _incBearing) * _incDist, 0]];
        _track set [5, _aimPos];
    };
};

// ── Bound the registry ──────────────────────────────────────────────────────
// Entered only while over the cap, and one insert can only push it one over, so
// this is one walk per insert at worst and none at all in the normal case. The
// OLDEST record goes rather than the new one being refused: losing the least recent
// fix is better than a live battery that stops being reported. The just-inserted
// track carries _now and so can never be the one dropped.
if (count GVAR(tracks) > TRACK_CAP) then {
    private _oldestKey = "";
    private _oldest = 1e11;
    {
        private _t = _y # 7;
        if (_t < _oldest) then {
            _oldest = _t;
            _oldestKey = _x;
        };
    } forEach GVAR(tracks);

    if (_oldestKey isNotEqualTo "") then {
        GVAR(tracks) deleteAt _oldestKey;
    };
};

// ── Send, or arm one deferred flush ─────────────────────────────────────────
// The fan-out is where this component's cost multiplies: one packet per hostile
// curator per round. A rocket battery empties twelve rounds in about two seconds,
// and twelve near-identical packets per curator say nothing the first and last do
// not. So a round arriving inside SEND_INTERVAL of the last send only bumps the
// counters, and arms a SINGLE bounded waitAndExecute to carry the final state out.
//
// The pending flag is what makes it single: without it a twelve-round salvo would
// arm twelve timers, which is worse than the twelve packets it set out to avoid.
// FUNC(sendContact) clears the flag, so the next round after a flush arms a new one.
private _due = (_track # 9) + SEND_INTERVAL;

if (_now >= _due) exitWith {
    [_gunId, _watchers] call FUNC(sendContact);
};

if (_track # 10) exitWith {};

_track set [10, true];
[FUNC(sendContact), [_gunId, []], _due - _now] call CBA_fnc_waitAndExecute;
