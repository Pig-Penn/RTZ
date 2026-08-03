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

private _m = createHashMap;
{ _m set [_x select 0, _x] } forEach _entries;

GVAR(unitData) = _m;
GVAR(unitTagsDirty) = true;
