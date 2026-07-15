#include "script_component.hpp"
/*
 * rtz_fnc_processMineQueue
 *
 * SERVER walk-and-plant chain for one mine-laying unit. Pops the next queued
 * position (GVAR(mineQueues)), walks the unit there, kneels it to plant, lays the
 * mine after a short delay (FUNC(layMineNow)), then recurses onto the next queued
 * spot. Fully unscheduled — the walk is watched by CBA_fnc_waitUntilAndExecute
 * with a distance-scaled timeout and the plant pause by CBA_fnc_waitAndExecute,
 * so there is no spawn/sleep and nothing pathfinds forever.
 *
 * lambs_danger_forceMove (inert without LAMBS) keeps the danger FSM from seizing
 * the unit mid-errand; setUnitPosWeak requests the pose without hard-locking it.
 * The chain self-terminates and rejoins the unit to formation when the queue is
 * empty, the unit dies/goes down, or it runs out of mines.
 *
 * Parameters:
 *   0: Object — mine-laying unit
 */

// Arrival threshold (m) and plant time (s).
#define LAY_RADIUS 3
#define LAY_DURATION 3

params ["_unit"];

private _key = netId _unit;
private _queue = GVAR(mineQueues) getOrDefault [_key, []];

// Drop the queue and rejoin formation. Shared by every stop path below.
private _fnc_cleanup = {
    params ["_unit", "_key"];
    GVAR(mineQueues) deleteAt _key;
    _unit setVariable [QGVAR(layingMine), nil];
    _unit setVariable ["lambs_danger_forceMove", nil];
    if (alive _unit) then {
        _unit setUnitPosWeak "AUTO";
        _unit doFollow (leader _unit);
    };
};

if (isNull _unit || {!alive _unit} || {lifeState _unit isEqualTo "INCAPACITATED"}) exitWith {
    [_unit, _key] call _fnc_cleanup;
};
if (_queue isEqualTo []) exitWith {
    [_unit, _key] call _fnc_cleanup;
};
if (([_unit] call FUNC(findMineMag)) isEqualTo "") exitWith {
    private _curator = _unit getVariable [QGVAR(mineCurator), objNull];
    if (!isNull _curator) then {
        [QGVAR(layMineMsg), ["Mine layer is out of mines"], _curator] call CBA_fnc_targetEvent;
    };
    [_unit, _key] call _fnc_cleanup;
};

_unit setVariable [QGVAR(layingMine), true];
_unit setVariable ["lambs_danger_forceMove", true];

private _target = _queue deleteAt 0;   // pop the head; mutates the stored array
private _curator = _unit getVariable [QGVAR(mineCurator), objNull];

_unit setUnitPosWeak "UP";
_unit doMove _target;

// CBA_fnc_waitUntilAndExecute passes the same args array (element 3) to the
// condition, the statement and the timeout code — so _curator rides along in it.
[
    { params ["_unit", "_target"]; !alive _unit || {_unit distance2D _target < LAY_RADIUS} },
    {
        params ["_unit", "_target"];
        if (!alive _unit) exitWith { [_unit] call FUNC(processMineQueue); };
        _unit setUnitPosWeak "MIDDLE";   // kneel to plant
        [
            {
                params ["_unit"];
                if (alive _unit) then { [_unit] call FUNC(layMineNow); };
                [_unit] call FUNC(processMineQueue);   // next queued spot (or cleanup)
            },
            [_unit],
            LAY_DURATION
        ] call CBA_fnc_waitAndExecute;
    },
    [_unit, _target, _curator],
    12 + (_unit distance2D _target) * 0.5,
    {
        // Timeout: couldn't reach this spot — skip it and continue the queue.
        params ["_unit", "_target", "_curator"];
        if (!isNull _curator) then {
            [QGVAR(layMineMsg), ["Mine layer couldn't reach the spot"], _curator] call CBA_fnc_targetEvent;
        };
        [_unit] call FUNC(processMineQueue);
    }
] call CBA_fnc_waitUntilAndExecute;
