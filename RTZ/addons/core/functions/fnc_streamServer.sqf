#include "script_component.hpp"
/*
 * Author: Maxim
 * SERVER ONLY. The ONE watcher registry and the ONE poll loop behind every
 * curator data feed — infantry packets, vehicle packets, destination overlays,
 * target overlays.
 *
 * This replaced three separate engines that had independently converged on the
 * same shape: a playerNetId registry, a subscribe event, a self-gating PFH, a
 * diff against the last payload actually sent, and a CBA_fnc_targetEvent push.
 * Keeping three meant three PFHs walking three registries and resolving the same
 * curator's selection three times per tick.
 *
 * Why the server: expectedDestination, assignedTarget, targetKnowledge and the
 * unit-state reads behind the packets are all AI brain state, which exists only
 * where the unit is LOCAL (docs/Knowledge Base/Gotchas.md §4). Normal AI is server-local, so
 * the server reads it and streams per-curator snapshots back. Per-curator
 * streams also keep it PvP-fair: a Zeus only watches what they can select, and
 * only sees what those units know.
 *
 * Each watcher's selection is resolved to its three slices ONCE per tick and
 * every due stream reads from that, so a curator running four displays pays for
 * one resolve pass, not four.
 *
 * Snapshots are DIFFED against the last one actually sent. The gather still runs
 * every tick — AI state has to be read to know it has not changed — but an
 * identical result is never re-serialized onto the network, so a squad walking a
 * long leg or a parked vehicle costs nothing after the first send. For the same
 * reason FUNC(gatherTarget) reports the ABSOLUTE time of the last sighting
 * rather than an age: an age changes every tick and would defeat the diff, while
 * a frozen timestamp diffs away and is aged client-side instead.
 *
 * Per-stream cadence: streams declare their own interval (FUNC(registerStream)),
 * read live from its CBA setting each tick and floored to STREAM_TICK, so the
 * 0.3 s unit/vehicle feeds and the 2 s overlay feeds share one loop without
 * either paying the other's rate. Due-ness is evaluated once per stream per
 * tick, not per watcher.
 *
 * Registry layout, keyed by player netId:
 *   [_player, _units, _vehs, _hulls, _streams, _detailed, _lastSent]
 *     _player   — the subscribing curator, null-checked each tick
 *     _units    — their selected infantry netIds (empty unless a consumer is up)
 *     _vehs     — their selected vehicle netIds
 *     _hulls    — their selection resolved to hulls, as OBJECTS
 *     _streams  — the overlay stream ids they currently have switched on
 *     _detailed — whether the info dialog is open (gates the expensive intel)
 *     _lastSent — stream id -> the entries last sent, the diff baseline
 *
 * Loading: called unconditionally from XEH_postInit under isServer, NOT from the
 *   CBA_settingsInitialized gate. The enable* settings are all isGlobal 0
 *   (per-client display preferences); gating this on one would make a dedicated
 *   server decide whether to feed its clients based on its own copy of a client
 *   preference — flip "Vehicle Tags" off in a server CBA config and every
 *   client's tags go permanently blank with nothing in the log to explain it.
 *   Registers one CBA event handler and one PFH, no scheduled ops.
 *
 * Arguments:
 * None
 *
 * Return Value:
 * None
 *
 * Example:
 * call rtz_core_fnc_streamServer
 *
 * Public: No
 */

if (!isServer) exitWith {};

GVAR(watchers) = createHashMap;

// Replace-set semantics: the client sends its full selection slices and its full
// active-stream list whenever any of them changes. A payload with nothing in any
// slice unsubscribes.
[QGVAR(watch), {
    // _detailed is type-checked: it arrives over a CLIENT-fired server event, and
    // the per-tick gather memo indexes on it.
    params ["_player", "_units", "_vehs", "_hulls", "_streams", ["_detailed", false, [false]]];
    if (isNull _player) exitWith {};

    private _pk = netId _player;

    if (_units isEqualTo [] && {_vehs isEqualTo []} && {_hulls isEqualTo [] || {_streams isEqualTo []}}) exitWith {
        if (_pk in GVAR(watchers)) then {
            (GVAR(watchers) deleteAt _pk) params ["", "", "", "", "_oldStreams"];
            // Final empty snapshot per overlay stream so the client's overlays
            // clear immediately instead of freezing on their last frame. The unit
            // and vehicle feeds need no equivalent: the client clears those maps
            // itself the moment it stops reporting them (see FUNC(selectionPoll)).
            {
                [QGVAR(update), [_x, [], time], _player] call CBA_fnc_targetEvent;
            } forEach _oldStreams;
        };
    };

    // A fresh subscription starts with no diff baseline, so the next tick always
    // sends — the client may have just pruned its own data and must not be left
    // waiting for a change that already happened.
    GVAR(watchers) set [_pk, [_player, _units, _vehs, _hulls, _streams, _detailed, createHashMap]];
}] call CBA_fnc_addEventHandler;

// ── Poll loop ────────────────────────────────────────────────────────────────
// Unscheduled per-frame handler rather than a spawned while/sleep: no scheduler
// starvation (docs/Knowledge Base/Gotchas.md §1). Bails cheaply when nobody is subscribed; no
// suspending commands in the body.
[{
    // _nextRuns: stream id -> the CBA_missionTime it may next run. Lives in the
    // PFH args so it persists across ticks without a global.
    (_this select 0) params ["_nextRuns"];
    if (count GVAR(watchers) == 0) exitWith {};

    private _now = CBA_missionTime;

    // Which streams are due THIS tick — evaluated once for the whole server, not
    // once per watcher. A stream with no registered gatherer is skipped outright.
    private _due = [];
    {
        // _x: stream id, _y: [gather, source, intervalVar, defaultInterval]
        _y params ["_gather", "_source", "_intervalVar", "_defaultInterval"];
        if (_now < (_nextRuns getOrDefault [_x, -1])) then { continue };
        // Plain getVariable, NOT the GETMVAR macro: _intervalVar already HOLDS
        // the setting's variable name as a string, and GETMVAR would QUOTE that
        // local's own name and look up the literal "_intervalVar".
        private _interval = missionNamespace getVariable [_intervalVar, _defaultInterval];
        _nextRuns set [_x, _now + (_interval max STREAM_TICK)];
        _due pushBack [_x, _gather, _source];
    } forEach GVAR(streams);
    if (_due isEqualTo []) exitWith {};

    private _sendTime = time;
    private _stale = [];

    // ── Per-tick gather memo ─────────────────────────────────────────────────
    // stream id -> (slice entry -> gathered entry).
    //
    // Every registered gatherer is a PURE function of its slice entry: it reads
    // the entity and nothing else — not the curator, not the player, not the
    // watcher record. So N curators whose selections overlap were paying N times
    // over for byte-identical answers, and gatherUnitInfo is not cheap (morale,
    // suppression, unit state, current command, life state, seven AI-feature
    // reads, weapon and magazine reads, a LAMBS variable, target resolution, and
    // a full targetsQuery when the dialog is open). Four curators on a shared
    // selection meant four times that per unit per tick.
    //
    // Keyed on the entry's ENTITY — element 0, an object in every slice shape —
    // and split into a plain and a detailed map per stream, so a curator with
    // the selection dialog open never receives the cheaper answer built for one
    // without. Objects are used as keys rather than the entry array because the
    // entity alone determines the result: for the hull slice the vehicle is
    // `vehicle _unit`, and two curators whose hull entries name different crewmen
    // of the same vehicle genuinely want separate answers, which this gives them.
    //
    // Everything downstream is untouched: each watcher still runs its own send
    // diff and gets its own targeted event. Only the COMPUTATION is shared,
    // turning O(curators x entities) into O(entities).
    //
    // Safe to share the resulting entry arrays by reference: no receiver or
    // renderer mutates one in place — the three overlay renderers' lazy bake
    // builds new arrays with `apply` and writes back to the RECORD, not the entry.
    //
    // Rebuilt every tick and dropped when this scope ends, so it cannot grow —
    // which matters on a multi-hour operation.
    private _memo = createHashMap;

    {
        // _x: player netId (key), _y: the watcher record. ALIAS THE KEY — the
        // inner loops rebind _x and leave it clobbered (docs/Knowledge Base/Gotchas.md §2).
        private _pk = _x;
        _y params ["_player", "_units", "_vehs", "_hulls", "_streams", "_detailed", "_lastSent"];

        // Disconnected players and ex-curators can't receive targetEvents — drop
        // them here so a vanished watcher can never null-error the send below.
        if (isNull _player || {isNull (getAssignedCuratorLogic _player)}) then {
            _stale pushBack _pk;
            continue;
        };

        // ── Resolve each slice ONCE for every stream that reads it ────────────
        // Built lazily: a curator with only the vehicle tags up never resolves
        // the hull list, and vice versa. nil means "not needed yet".
        private _srcUnits = nil;
        private _srcVehs  = nil;
        private _srcHulls = nil;

        // Virtual Zeus (VirtualMan_F) is the game master, not a PvP officer —
        // exempt from the own-side filter, matching the client poll.
        private _anySide = _player isKindOf "VirtualMan_F";
        private _cSide   = side _player;

        {
            _x params ["_stream", "_gather", "_source"];

            // Overlay streams (SRC_HULLS) only run while the curator has them
            // switched on; the unit and vehicle feeds are implied by a non-empty
            // slice. Gated HERE rather than inside the resolve below because
            // `continue` does not reliably escape a `switch do` case block — its
            // scope is the case, not the loop.
            if (_source == SRC_HULLS && {!(_stream in _streams)}) then { continue };

            private _list = switch (_source) do {
                case SRC_UNITS: {
                    if (isNil "_srcUnits") then {
                        // Re-capped even though the client capped: this list
                        // arrives over a client-fired server event, so the bound
                        // is not the client's to promise.
                        _srcUnits = [];
                        {
                            private _u = objectFromNetId _x;
                            if (!isNull _u && {alive _u}) then { _srcUnits pushBack [_u, _x, _detailed] };
                        } forEach (_units select [0, SEL_MAX_UNITS]);
                    };
                    _srcUnits
                };
                case SRC_VEHS: {
                    if (isNil "_srcVehs") then {
                        _srcVehs = [];
                        {
                            private _v = objectFromNetId _x;
                            if (!isNull _v && {alive _v}
                                && {_anySide || {VEH_SIDE_OK(_v,_cSide)}}) then {
                                _srcVehs pushBack [_v, _x, _detailed];
                            };
                        } forEach (_vehs select [0, SEL_MAX_VEHICLES]);
                    };
                    _srcVehs
                };
                default {
                    if (isNil "_srcHulls") then {
                        // A watched man may have mounted a watched vehicle since
                        // the last selection sync — both resolve to the same hull.
                        // The watched entity rides alongside its hull because it
                        // is what the client matches snapshots against.
                        _srcHulls = [];
                        private _seen = [];
                        {
                            if (isNull _x || {!alive _x}) then { continue };
                            private _veh = vehicle _x;
                            if (_veh in _seen) then { continue };
                            _seen pushBack _veh;
                            _srcHulls pushBack [_x, _veh, _detailed];
                        } forEach _hulls;
                    };
                    _srcHulls
                };
            };

            // NOT short-circuited on an empty slice. An empty result still has to
            // reach the diff: a feed whose entities all died or all failed their
            // filter must send [] ONCE so the client clears, and skipping the send
            // would leave the last non-empty snapshot on screen indefinitely. The
            // diff then suppresses every repeat, so the idle cost is one compare.

            // Slice entries are built with the "dialog open" flag already appended,
            // so the gatherer's argument list is flat and no array is allocated
            // per entity per tick just to carry it.
            // Shared across every watcher this tick — see the memo note above.
            // [plain, detailed]; isEqualTo rather than a bare select so a
            // malformed flag can never throw on the index (it returns false).
            private _streamMemo = _memo getOrDefault [_stream, [createHashMap, createHashMap], true];
            private _entryMemo  = _streamMemo select (parseNumber (_detailed isEqualTo true));

            private _entries = [];
            {
                // Closed over rather than read from `_this`: getOrDefaultCall
                // runs its default block with _this set to [key, hashMap], not
                // the key (docs/Knowledge Base/Gotchas.md §3).
                private _sliceEntry = _x;
                private _entry = _entryMemo getOrDefaultCall [
                    _sliceEntry select 0, {_sliceEntry call _gather}, true
                ];
                if (_entry isNotEqualTo []) then { _entries pushBack _entry };
            } forEach _list;

            // Nothing changed since the last send — the client's display is
            // already correct, so say nothing. objNull default so a missing
            // baseline never compares equal to any array.
            if (_entries isEqualTo (_lastSent getOrDefault [_stream, objNull])) then { continue };
            _lastSent set [_stream, _entries];

            [QGVAR(update), [_stream, _entries, _sendTime], _player] call CBA_fnc_targetEvent;
        } forEach _due;
    } forEach GVAR(watchers);

    { GVAR(watchers) deleteAt _x } forEach _stale;
}, STREAM_TICK, [createHashMap]] call CBA_fnc_addPerFrameHandler;
