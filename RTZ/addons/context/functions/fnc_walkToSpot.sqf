#include "script_component.hpp"
/*
 * rtz_fnc_walkToSpot
 *
 * SERVER: send one or more errand units walking to a spot, then run a completion
 * callback — shared by the assemble (crew walks to the build spot) and disassemble
 * (assistant walks to the weapon) flows, which previously duplicated this block.
 *
 * lambs_danger_forceMove (inert without LAMBS) keeps the danger FSM from seizing
 * the units mid-errand; setUnitPosWeak requests the pose without hard-locking it.
 * Fully unscheduled: the walk is watched by CBA_fnc_waitUntilAndExecute with a
 * distance-scaled timeout — no spawn/sleep, nothing pathfinds forever. The
 * callback runs on arrival of the FIRST unit (or its death, letting the callback
 * abort), and on timeout after toasting the curator, so the errand always
 * completes. Callers release the units via FUNC(clearErrandState).
 *
 * Parameters:
 *   0: Array  — units to walk (first entry is the one watched for arrival)
 *   1: Array  — world position to walk to
 *   2: Code   — completion callback, receives _completeArgs as _this
 *   3: Array  — arguments for the callback (default [])
 *   4: String — curator toast on timeout ("" for none; default "")
 *   5: Object — ordering curator's player (feedback toasts; may be objNull)
 */

// Arrival threshold (m); walk timeout base (s), scaled by distance below.
#define ARRIVE_RADIUS 4
#define WALK_TIMEOUT_BASE 12

params ["_units", "_pos", "_onComplete", ["_completeArgs", []], ["_timeoutMsg", ""], ["_curator", objNull]];

private _lead = _units param [0, objNull];
if (isNull _lead) exitWith {};

{
    _x setVariable ["lambs_danger_forceMove", true];
    _x setUnitPosWeak "UP";
    _x doMove _pos;
} forEach (_units select { !isNull _x && {alive _x} });

[
    { params ["_lead", "_pos"]; !alive _lead || {_lead distance2D _pos < ARRIVE_RADIUS} },
    { params ["", "", "_onComplete", "_completeArgs"]; _completeArgs call _onComplete },
    [_lead, _pos, _onComplete, _completeArgs, _timeoutMsg, _curator],
    WALK_TIMEOUT_BASE + (_lead distance2D _pos) * 0.5,
    {
        params ["", "", "_onComplete", "_completeArgs", "_timeoutMsg", "_curator"];
        [_curator, _timeoutMsg] call FUNC(assembleToast);
        _completeArgs call _onComplete;
    }
] call CBA_fnc_waitUntilAndExecute;
