#include "script_component.hpp"
/*
 * Author: Maxim
 * CLIENT. Snapshot receiver for the vehicle packet feed (STREAM_VEH).
 *
 * Same netId-keyed unpack as FUNC(receiveUnitData), and for the same reason: the
 * consumer indexes by id. The head tags (FUNC(drawVehicleTags)) read the store, and
 * the same walk that builds it names the vehicles whose per-vehicle text cache is
 * genuinely stale — which is what the renderer rebuilds, rather than all of them.
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

// Per-packet cache invalidation, the twin of FUNC(receiveUnitData)'s — see there for
// the reasoning and FUNC(markTagsDirty) for the two modes. This packet is value-typed
// throughout as well: FUNC(gatherVehicleInfo) sends the effective commander as a netId
// STRING rather than the object, its flags as strings and its ammo bars as number
// pairs, so the deep compare is meaningful.
private _old   = GVAR(vehicleData);
private _m     = createHashMap;
private _dirty = [];
{
    private _pid = _x select 0;
    _m set [_pid, _x];
    private _prev = _old get _pid;
    if (isNil "_prev" || {_prev isNotEqualTo _x}) then { _dirty pushBack _pid };
} forEach _entries;

{ if !(_x in _m) then { _dirty pushBack _x } } forEach keys _old;

GVAR(vehicleData) = _m;
[QGVAR(vehicleTags), _dirty] call FUNC(markTagsDirty);
