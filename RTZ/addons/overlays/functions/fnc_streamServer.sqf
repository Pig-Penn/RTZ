#include "script_component.hpp"
/*
 * Author: Maxim
 * SERVER half of the overlay stream engine — ONE watcher registry and ONE poll
 * loop for every overlay, in place of a full copy per overlay.
 *
 * expectedDestination, assignedTarget and targetKnowledge all read AI state
 * that only exists where the unit is LOCAL. Normal AI is server-local, so the
 * server polls each curator's watched units and streams per-curator snapshots
 * back via CBA_fnc_targetEvent; non-server-local units (remote control,
 * headless clients) are skipped by the gatherers. Per-curator streams also keep
 * it PvP-fair — a Zeus only watches units they can select, and only sees what
 * those units know.
 *
 * Each watcher's selection is resolved to hulls ONCE per tick and every active
 * gatherer walks that one list, so a curator running both overlays pays for one
 * resolve pass, not two.
 *
 * Snapshots are DIFFED against the last one actually sent (the same trick
 * EFUNC(selection,selectionGather) uses): the gather still runs every tick —
 * AI state has to be read to know it has not changed — but an identical result
 * is never re-serialized onto the network. A squad walking a long leg reports
 * the same destination every tick and therefore costs nothing after the first
 * send. For the same reason FUNC(gatherTarget) reports the ABSOLUTE time of the
 * last sighting rather than an age: an age changes every tick and would defeat
 * the diff, while stale intel with a frozen timestamp diffs away and is aged
 * client-side instead.
 *
 * Registry layout, keyed by player netId:
 *   [_player, _watched, _streams, _lastSent]
 *     _player   — the subscribing curator, null-checked each tick
 *     _watched  — their resolved selection, replaced wholesale on every change
 *     _streams  — the stream ids they currently have switched on
 *     _lastSent — stream id -> the entries last sent to them, the diff baseline
 *
 * Loading: called unconditionally from XEH_postInit (see the note there).
 * Registers one CBA event handler and one PFH, no scheduled ops.
 *
 * Arguments:
 * None
 *
 * Return Value:
 * None
 *
 * Example:
 * call rtz_overlays_fnc_streamServer
 *
 * Public: No
 */

if (!isServer) exitWith {};

GVAR(watchers) = createHashMap;

// Stream id -> its gather function. LINKFUNC rather than a stored Code value so
// a PREP recompile is picked up.
GVAR(gatherFncs) = createHashMapFromArray [
    [STREAM_DEST, LINKFUNC(gatherDestination)],
    [STREAM_TGT,  LINKFUNC(gatherTarget)]
];

// Replace-set semantics: the client sends its full resolved selection and its
// full active-stream list whenever either changes. An empty selection, or no
// active stream, unsubscribes.
[QGVAR(watch), {
    params ["_player", "_watched", "_streams"];
    if (isNull _player) exitWith {};

    private _pk = netId _player;
    _watched = _watched select {!isNull _x};

    if (_watched isEqualTo [] || {_streams isEqualTo []}) exitWith {
        if (_pk in GVAR(watchers)) then {
            (GVAR(watchers) deleteAt _pk) params ["", "", "_oldStreams"];
            // Final empty snapshot per stream so the client's overlays clear
            // immediately instead of freezing on their last frame.
            {
                [QGVAR(update), [_x, [], time], _player] call CBA_fnc_targetEvent;
            } forEach _oldStreams;
        };
    };

    // A fresh subscription starts with no diff baseline, so the next tick always
    // sends — the client has just pruned its own data and must not be left
    // waiting for a change that already happened.
    GVAR(watchers) set [_pk, [_player, _watched, _streams, createHashMap]];
}] call CBA_fnc_addEventHandler;

// ── Poll loop ────────────────────────────────────────────────────────────────
// Unscheduled per-frame handler (RTZ server-loop convention) rather than a
// spawned while/sleep: no scheduler starvation. Ticks at POLL_TICK and
// self-gates on the live GVAR(pollInterval) setting, so admins can retune the
// cadence mid-mission. Bails cheaply when nobody is subscribed; no suspending
// commands in the body.
[{
    (_this select 0) params ["_nextRun"];
    if (CBA_missionTime < _nextRun) exitWith {};
    (_this select 0) set [0, CBA_missionTime + ((GETGVAR(pollInterval,2)) max POLL_TICK)];
    if (count GVAR(watchers) == 0) exitWith {};

    private _now = time;
    private _stale = [];

    {
        // _x: player netId (key), _y: [player, watched, streams, lastSent].
        _y params ["_player", "_watched", "_streams", "_lastSent"];
        // Disconnected players can't receive targetEvents — drop them here so a
        // vanished watcher can never null-error the send below.
        if (isNull _player) then { _stale pushBack _x; continue };

        // Resolve the watch set to live hulls ONCE for every active stream. A
        // watched man may have mounted a watched vehicle since the last
        // selection sync — both resolve to the same hull, which moves and
        // fights as one. The watched entity itself is carried alongside its hull
        // because it is what the client matches snapshots against.
        private _hulls = [];
        private _seen  = [];
        {
            if (isNull _x || {!alive _x}) then { continue };
            private _veh = vehicle _x;
            if (_veh in _seen) then { continue };
            _seen pushBack _veh;
            _hulls pushBack [_x, _veh];
        } forEach _watched;

        {
            private _gather = GVAR(gatherFncs) get _x;
            if (isNil "_gather") then { continue };

            private _entries = [];
            {
                private _entry = _x call _gather;
                if (_entry isNotEqualTo []) then { _entries pushBack _entry };
            } forEach _hulls;

            // Nothing changed since the last send — the client's overlay is
            // already correct, so say nothing.
            if (_entries isEqualTo (_lastSent getOrDefault [_x, false])) then { continue };
            _lastSent set [_x, _entries];

            [QGVAR(update), [_x, _entries, _now], _player] call CBA_fnc_targetEvent;
        } forEach _streams;
    } forEach GVAR(watchers);

    { GVAR(watchers) deleteAt _x } forEach _stale;
}, POLL_TICK, [0]] call CBA_fnc_addPerFrameHandler;
