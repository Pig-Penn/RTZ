#include "script_component.hpp"
/*
 * Author: Maxim
 * SERVER ONLY. Declare one data feed to the shared stream engine
 * (FUNC(streamServer)). A new curator display costs a gather/draw pair and one
 * call to this — never another registry, PFH, subscribe event or diff cache.
 *
 * The gatherer is handed one entry from the slice its stream declared, plus the
 * watcher's "dialog open" flag for feeds whose expensive fields only matter to
 * the dialog, and returns one snapshot entry — or [] to omit this entity from
 * the snapshot entirely:
 *
 *   SRC_UNITS / SRC_VEHS — [[object, netId], detailed]
 *   SRC_HULLS            — [[watchedEntity, hull], detailed]
 *
 * Cadence is a SETTING NAME plus a fallback, not a fixed number, so an admin can
 * retune a feed mid-mission and the loop picks it up on its next tick. It is
 * floored to STREAM_TICK — no feed can outrun the loop that drives it.
 *
 * LINKFUNC rather than a stored Code value for the gatherer, so a PREP recompile
 * is picked up without re-registering.
 *
 * Arguments:
 * 0: Stream id <STRING>
 * 1: Gather function <CODE>
 * 2: Selection slice to feed it — SRC_UNITS, SRC_VEHS or SRC_HULLS <NUMBER>
 * 3: Variable name of the CBA interval setting <STRING>
 * 4: Interval fallback (s), used before settings sync and if unset <NUMBER>
 *
 * Return Value:
 * None
 *
 * Example:
 * [STREAM_VEH, LINKFUNC(gatherVehicleInfo), SRC_VEHS, QGVAR(gatherInterval), 0.3] call rtz_hud_fnc_registerStream
 *
 * Public: No
 */

params ["_stream", "_gather", "_source", "_intervalVar", "_defaultInterval"];

if (!isServer) exitWith {};

GVAR(streams) set [_stream, [_gather, _source, _intervalVar, _defaultInterval]];
