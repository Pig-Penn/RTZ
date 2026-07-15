#include "script_component.hpp"
/*
 * rtz_fnc_layMineApply
 *
 * SERVER handler body for QGVAR(layMine) (registered in XEH_postInit). Queues a
 * position for the given unit to lay a mine at, then kicks off the walk-and-plant
 * chain (FUNC(processMineQueue)) if the unit is not already working its queue.
 * doMove / createMine run where the unit is local — the server, for AI in Zeus
 * PvP — so the whole errand lives here.
 *
 * The per-unit queue (GVAR(mineQueues): unit netId -> array of positions) lets a
 * curator rapid-click several spots; each click appends to the same queue and a
 * single running chain drains it in order. On failure the ordering curator is
 * toasted via QGVAR(layMineMsg).
 *
 * Parameters:
 *   0: Object — mine-carrying unit chosen by the client
 *   1: Array  — world position to lay the mine at
 *   2: Object — ordering curator's player (for feedback toasts); may be objNull
 */

params ["_unit", "_pos", ["_curator", objNull]];

if (isNull _unit || {!alive _unit}) exitWith {};
if (!local _unit) exitWith {
    if (!isNull _curator) then {
        [QGVAR(layMineMsg), ["Mine layer is not on this machine"], _curator] call CBA_fnc_targetEvent;
    };
};
if (([_unit] call FUNC(findMineMag)) isEqualTo "") exitWith {
    if (!isNull _curator) then {
        [QGVAR(layMineMsg), ["Selected unit has no mines"], _curator] call CBA_fnc_targetEvent;
    };
};

// getOrDefault with insertDefault=true stores (and returns by reference) a fresh
// queue the first time, so the pushBack below persists in the map.
private _queue = GVAR(mineQueues) getOrDefault [netId _unit, [], true];
_queue pushBack _pos;
_unit setVariable [QGVAR(mineCurator), _curator];

// Start draining only if no chain is already running for this unit; an active
// chain will pick up the newly-queued position on its next leg.
if !(_unit getVariable [QGVAR(layingMine), false]) then {
    [_unit] call FUNC(processMineQueue);
};
