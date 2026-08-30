#include "script_component.hpp"
/*
 * Author: Maxim
 * CLIENT. Snapshot receiver for the infantry packet feed (STREAM_UNIT).
 *
 * Unpacked into a netId-keyed map here rather than stored raw, because its
 * consumers — the head tags (FUNC(drawUnitTags)) and the selection dialog rows
 * (FUNC(buildSelectionRows)) — both index by id. Doing it once on receipt beats a
 * linear scan per lookup per frame.
 *
 * Packet layout is FUNC(gatherUnitInfo)'s; index 0 is the netId.
 *
 * This was a `case STREAM_UNIT` inside EFUNC(core,streamClient), which is what made that
 * "generic" receiver know the ids of two specific displays. It is registered with
 * the stream now (EFUNC(core,registerStream)), so the engine dispatches without knowing
 * what it is dispatching to.
 *
 * The reference time is not consumed here, but NOT because the packet is free of
 * aged fields — index 17 (dangerTimeout) is a countdown resolved at gather time,
 * the one field in this component that reports a relative figure rather than an
 * absolute stamp (contrast FUNC(gatherTarget), which sends the sighting time raw
 * and lets FUNC(drawTarget) age it against exactly this argument). It is left as
 * it is deliberately: converting it would buy nothing, because dangerDist, morale,
 * suppression, ammo and health in the same packet all move continuously, so a unit
 * in contact defeats EFUNC(core,streamServer)'s send diff regardless. The countdown
 * is simply displayed a poll-interval stale.
 *
 * Arguments:
 * 0: Stream id <STRING> (unused — one receiver, one stream)
 * 1: Snapshot entries <ARRAY>
 * 2: Server clock at send <NUMBER> (unused — see above)
 *
 * Return Value:
 * None
 *
 * Example:
 * [_stream, _entries, _refTime] call rtz_hud_fnc_receiveUnitData
 *
 * Public: No
 */

params ["", "_entries"];

// The unpack doubles as the tag cache's invalidation diff — see FUNC(markTagsDirty)
// for why per-packet and not wholesale. This is the SAME comparison
// EFUNC(core,streamServer) already makes to decide whether to send at all (it runs
// `_entries isEqualTo _lastSent`, a deep compare over an array of these very
// packets); the client simply threw that granularity away on arrival. Neither packet
// layout carries an OBJECT — FUNC(gatherUnitInfo) is netIds, bools, strings, numbers
// and a string array — so isNotEqualTo answers the question actually being asked.
private _old   = GVAR(unitData);
private _m     = createHashMap;
private _dirty = [];
{
    private _pid = _x select 0;
    _m set [_pid, _x];
    private _prev = _old get _pid;
    if (isNil "_prev" || {_prev isNotEqualTo _x}) then { _dirty pushBack _pid };
} forEach _entries;

// Entries whose unit has left the snapshot. The wholesale wipe used to drop these as
// a side effect, so they have to be collected explicitly or the cache keeps a slot
// per unit ever selected for the rest of the mission. `keys` returns a copy, and
// nothing here mutates _old anyway.
{ if !(_x in _m) then { _dirty pushBack _x } } forEach keys _old;

GVAR(unitData) = _m;
[QGVAR(unitTags), _dirty] call FUNC(markTagsDirty);
// The selection dialog reads GVAR(unitData) too, and its row model is far more
// expensive to build than a tag string — see the gate in FUNC(openSelectionInfo).
GVAR(selRowsDirty) = true;
