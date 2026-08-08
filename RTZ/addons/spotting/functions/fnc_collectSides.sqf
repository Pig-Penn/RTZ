#include "script_component.hpp"
/*
 * Author: Maxim
 * Resolves one detection tick's SIDE picture for FUNC(spotCheck): which sides have a
 * manned curator, every spottable hostile candidate bucketed by side, and one
 * representative spotter per local AI group on each side that has a curator.
 *
 * Split out of FUNC(spotCheck) because it runs exactly ONCE per tick, whereas the
 * detection loop it feeds runs per group per curator side — so the extra `call` is
 * free here, and it keeps the hot loop readable. Everything in this file is
 * O(curators + allUnits + vehicles); nothing in it is per-contact.
 *
 * Every map returned is keyed on the SIDE OBJECT, not on `str side`. Side is a legal
 * HashMap key (Gotchas §3 lists it among Number/Bool/Array/String/Namespace/NaN/Code/
 * Side/Config entry), and the string form cost one `str` allocation per entity per
 * tick across both engine lists below — squarely the per-entity-per-tick `str` that
 * CLAUDE.md rules out on a mission running for hours. FUNC(spotCheck) still derives
 * one string per curator SIDE for its latch and callout keys, which is a handful per
 * tick rather than one per unit.
 *
 * Mutates GVAR(spotResendPlayers): a player's pending resync request is retired HERE,
 * on the first tick that player resolves to a targetable curator, and folded into that
 * destination's own force flag. Retiring at the point of resolution — rather than
 * consuming a global flag at the top of the pass — is what lets a request that arrived
 * before the mission assigned the curator module still be honoured (FUNC(spottingSystem)).
 *
 * Arguments:
 * 0: Curator logic modules to consider (already null-filtered) <ARRAY>
 * 1: Global force-resend flag for this tick, folded into each curator's own flag <BOOL>
 * 2: Diagnostic logging on (RTZ_debug) — also forces the classification pass to run
 *    with no curator resolved, so the logged spotter-group count is real <BOOL>
 *
 * Return Value:
 * [
 *   0: side → curator tuples [curator, player, curatorNetId, forceResend] <HASHMAP>,
 *   1: side → spottable hostile candidates <HASHMAP>,
 *   2: side → HashMap(group netId → representative spotter unit) <HASHMAP>
 * ] <ARRAY>
 *
 * Example:
 * ([_curators, _forceResend, _dbg] call rtz_spotting_fnc_collectSides) params ["_bySide", "_sideEntities", "_sideSpotterReps"];
 *
 * Public: No
 */

params ["_curators", "_forceResend", "_dbg"];

// ── Group manned curators by side ────────────────────────────────────────────
// Resolved BEFORE the unit/vehicle classification so a tick with no manned curator —
// vacant Zeus slots, a headless-only setup — skips the O(allUnits + vehicles)
// bucketing entirely.
// Only PLAYER-manned curators can be spotters — a live player object is required as
// the CBA_fnc_targetEvent destination. Headless curators are skipped entirely, and so
// are curator modules still bound to a departed player: a playable Zeus slot whose AI
// is not disabled leaves the unit object behind, so getAssignedCuratorUnit keeps
// returning a non-null, server-local, NON-player body. `owner` of that body is 2, so an
// isNull-only guard would route every one of that curator's spots to the server — a
// silent no-op on a dedicated server (whose keys then never age out of the active-spot
// map), but on a listen server the host has the receivers registered and would render a
// departed curator's entire contact picture as its own. isPlayer is the same test
// FUNC(remoteControlIndicator) already uses, and `isPlayer objNull` is false, so it
// subsumes the null check.
// Same-side curators share the same spotter pool and see the same hostiles, so the
// entire knowsAbout matrix is computed once per side and emitted to each.
// The player's netId is resolved here for the pending-resync lookup but is NOT carried:
// it used to ride along so every signature could be suffixed with it, which
// FUNC(emitSpot) now detects directly as a recipient change instead.
private _bySide = createHashMap;
{
    private _player = getAssignedCuratorUnit _x;
    if (!isPlayer _player) then { continue };
    private _curatorSide = side _player;
    private _playerId    = netId _player;

    private _pending = _playerId in GVAR(spotResendPlayers);
    if (_pending) then { GVAR(spotResendPlayers) deleteAt _playerId };

    (_bySide getOrDefault [_curatorSide, [], true])
        pushBack [_x, _player, netId _x, _forceResend || _pending];
} forEach _curators;

// ── Classify every unit and vehicle ONCE per tick ────────────────────────────
// _sideEntities:    side → spottable hostile candidates (alive, non-player; locality
//                   NOT filtered: knowsAbout only requires the SPOTTER to be local, and
//                   targets may sit on a client, e.g. under curator remote control).
// _sideSpotterReps: side → HashMap(group netId → representative unit), collected ONLY
//                   for sides that actually have a manned curator (_bySide keys) — no
//                   other side's knowledge is ever queried, so building its rep map
//                   would be pure waste.
//                   Target knowledge is stored per GROUP, so one member answers
//                   knowsAbout for the whole group; crewed vehicles are covered by their
//                   effective commander (a vehicle's knowledge IS its crew group's), and
//                   empty vehicles — which know nothing — drop out. `local` keeps the
//                   knowsAbout source server-local and excludes AI in player-led groups
//                   (local to that player's client). Spotter units are drawn from ALL
//                   server-local AI (not just curatorEditableObjects) so that
//                   dynamically-spawned units from a late-joining curator are never
//                   missed due to editable-object list lag.
// Men and vehicles are looped separately — allUnits is alive-only and all CAManBase, so
// the men's loop needs no alive/kind checks and no merged array is allocated. Buckets are
// fetched with get + isNil (not getOrDefault) so the default array/hashmap isn't
// allocated per entity on the hit path. Units with simulation disabled are skipped
// entirely — neither spottable (they present no meaningful target) nor usable as a
// spotter rep.
// The whole pass is gated on a curator having resolved this tick — with _bySide empty
// nothing downstream would ever read its output. RTZ_debug forces it so the per-curator
// resolution log below can report a real spotter-group count.
private _sideEntities    = createHashMap;
private _sideSpotterReps = createHashMap;

if (count _bySide == 0 && {!_dbg}) exitWith { [_bySide, _sideEntities, _sideSpotterReps] };

{
    if (isPlayer _x) then { continue };
    if (!simulationEnabled _x) then { continue };
    private _eSide  = side _x;
    private _bucket = _sideEntities get _eSide;
    if (isNil "_bucket") then {
        _bucket = [];
        _sideEntities set [_eSide, _bucket];
    };
    _bucket pushBack _x;

    if (_eSide in _bySide && { local _x } && { !isNull group _x }) then {
        private _reps = _sideSpotterReps get _eSide;
        if (isNil "_reps") then {
            _reps = createHashMap;
            _sideSpotterReps set [_eSide, _reps];
        };
        _reps set [netId group _x, _x];
    };
} forEach allUnits;

{
    if (!alive _x || { isPlayer _x }) then { continue };
    if (!simulationEnabled _x) then { continue };
    if !(_x isKindOf "LandVehicle"
        || { _x isKindOf "Air" }
        || { _x isKindOf "Ship" }) then { continue };
    private _eSide = side _x;

    // Spottable only when the hull's group has a man leader. The grouping pass in
    // FUNC(spotCheck) keys on `leader group` and discards anything answering objNull, so
    // a hull without one never produced an icon anyway — it was merely walked once per
    // curator side first. `vehicles` is every vehicle on the map, which on a populated
    // terrain means hundreds of alive ambient cars, so testing it here keeps them out of
    // the hostile union and out of the per-side grouping walk entirely.
    if (!isNull (leader group _x)) then {
        private _bucket = _sideEntities get _eSide;
        if (isNil "_bucket") then {
            _bucket = [];
            _sideEntities set [_eSide, _bucket];
        };
        _bucket pushBack _x;
    };

    // Spotter rep regardless of the above: UAV crew are absent from allUnits (see
    // allUnitsUAV), so a UAV's knowledge is only reachable via its hull's effective
    // commander here.
    if (_eSide in _bySide && { local _x }) then {
        private _rep = effectiveCommander _x;
        if (!isNull _rep && { !isPlayer _rep } && { !isNull group _rep }) then {
            private _reps = _sideSpotterReps get _eSide;
            if (isNil "_reps") then {
                _reps = createHashMap;
                _sideSpotterReps set [_eSide, _reps];
            };
            _reps set [netId group _rep, _rep];
        };
    };
} forEach vehicles;

// Diagnostic: each curator's resolution is logged the first time it changes — THE check
// for "does the server resolve joined/JIP clients' curators to a targetable player?". A
// curator that logs owner=-1, or never logs at all, is being silently skipped; the logged
// player object is the raw getAssignedCuratorUnit result, so a curator held by a departed
// player shows a non-null body next to owner=-1. Runs after the classification (which
// _dbg forces on even with no curator resolved) so spotterGroups is the real rep count for
// the curator's side — an unresolved curator reads side sideUnknown, whose bucket is
// always empty, matching its true picture.
if (_dbg) then {
    private _emptyMap = createHashMap;
    {
        private _player = getAssignedCuratorUnit _x;
        private _curatorSide = if (!isPlayer _player) then { sideUnknown } else { side _player };
        private _repCount = count (_sideSpotterReps getOrDefault [_curatorSide, _emptyMap]);
        private _sig = format ["%1|%2|%3", _player, _curatorSide, _repCount];

        if (_sig != (GVAR(spotDebugLast) getOrDefault [netId _x, ""])) then {
            GVAR(spotDebugLast) set [netId _x, _sig];
            diag_log text format ["[RTZ] server curator %1: player=%2 owner=%3 side=%4 spotterGroups=%5",
                netId _x, _player, (if (!isPlayer _player) then {-1} else {owner _player}), _curatorSide, _repCount];
        };
    } forEach _curators;
};

[_bySide, _sideEntities, _sideSpotterReps]
