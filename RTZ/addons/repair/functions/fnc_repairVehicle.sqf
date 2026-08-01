#include "script_component.hpp"
/*
 * Author: Maxim
 * Handler body for QGVAR(repair) (registered in XEH_postInit). Walks one engineer
 * to a damaged vehicle and hands him to FUNC(startRepair) on arrival. Must be
 * executed where the engineer is local.
 *
 * The walk runs on the shared EFUNC(common,approach) engine — unscheduled, with a
 * distance-scaled timeout so nothing pathfinds forever into an unreachable vehicle,
 * and with the LAMBS force-move flag held for the duration so the danger FSM cannot
 * seize the engineer mid-errand. Crucially, approach's order counter is the SAME
 * one every other RTZ errand uses, so a mine or loot order issued to this engineer
 * mid-walk cleanly supersedes the repair instead of running alongside it.
 *
 * The engineer is sent to a point on the RING around the vehicle rather than to its
 * center: doMove onto the hull makes the engine path him into the vehicle and he
 * never settles. The slot fans co-workers apart so they don't fight for one spot.
 *
 * Arguments:
 * 0: Unit <OBJECT>
 * 1: Vehicle <OBJECT>
 * 2: Fan Slot <NUMBER> — position in the ring around the vehicle (default 0)
 * 3: Curator <OBJECT> — toast target if the engineer can't reach it (default objNull)
 *
 * Return Value:
 * None
 *
 * Example:
 * [_unit, _vehicle, 0, player] call rtz_repair_fnc_repairVehicle
 *
 * Public: No
 */

params ["_unit", "_vehicle", ["_slot", 0], ["_curator", objNull]];

if (!alive _unit || {isNull _vehicle} || {!alive _vehicle}) exitWith {};

// Stand clear of the hull: out past the widest half-axis of the bounding box,
// fanned by slot so several engineers ring the vehicle instead of stacking on one
// point. Taken from the min/max corners rather than any packed radius element, so
// it holds whatever arity boundingBoxReal returns
(boundingBoxReal _vehicle) params ["_bbMin", "_bbMax"];

private _radius = (((_bbMax select 0) - (_bbMin select 0)) max ((_bbMax select 1) - (_bbMin select 1))) / 2;
private _position = _vehicle getPos [(_radius max 1) + APPROACH_DISTANCE, (_vehicle getDir _unit) + _slot * FAN_BEARING];

[
    [_unit],
    _position,
    ARRIVE_DISTANCE,
    (WALK_TIMEOUT_BASE + (_unit distance2D _position) * WALK_TIMEOUT_PER_METER) max GVAR(repairTimeout),
    {
        params ["_unit", "_vehicle"];

        // Another engineer may have finished the job while this one walked up
        if (!alive _vehicle || {damage _vehicle <= REPAIR_THRESHOLD}) exitWith {
            [_unit] call EFUNC(common,clearErrand);
        };

        [_unit, _vehicle] call FUNC(startRepair);
    },
    // Errand expired or the engineer died — drop the guard/pose and rejoin
    // formation (skipped when a newer order superseded this one; approach skips
    // onFail then). clearErrand ignores the extra _args entries, so it is a hook
    // as-is.
    ELINKFUNC(common,clearErrand),
    [_unit, _vehicle],
    true,                           // forceMove: hold the engineer against the LAMBS danger FSM mid-walk
    _curator,
    LLSTRING(RepairUnreachable)
] call EFUNC(common,approach);
