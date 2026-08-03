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
 * Arguments:
 * 0: Stream id <STRING> (unused — one receiver, one stream)
 * 1: Snapshot entries <ARRAY>
 * 2: Server clock at send <NUMBER> (unused — these packets carry no aged field)
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
