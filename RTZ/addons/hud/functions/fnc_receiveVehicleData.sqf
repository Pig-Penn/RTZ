#include "script_component.hpp"
/*
 * Author: Maxim
 * CLIENT. Snapshot receiver for the vehicle packet feed (STREAM_VEH).
 *
 * Same netId-keyed unpack as FUNC(receiveUnitData), and for the same reason: both
 * consumers index by id. Here there are two of them sharing one feed — the head
 * tags (FUNC(drawVehicleTags)) and the bottom-right stat cards
 * (FUNC(drawVehicleCards)) — hence two dirty flags off one snapshot.
 *
 * Packet layout is FUNC(gatherVehicleInfo)'s; index 0 is the netId.
 *
 * Was a `case STREAM_VEH` inside EFUNC(core,streamClient); see EFUNC(core,registerStream) for
 * why the engine no longer carries it.
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
 * [_stream, _entries, _refTime] call rtz_hud_fnc_receiveVehicleData
 *
 * Public: No
 */

params ["", "_entries"];

private _m = createHashMap;
{ _m set [_x select 0, _x] } forEach _entries;

GVAR(vehicleData) = _m;
GVAR(vehicleTagsDirty) = true;
GVAR(vehicleDataDirty) = true;
