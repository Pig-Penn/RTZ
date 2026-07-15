#include "script_component.hpp"
/*
 * Author: Maxim
 * Moves an engineer to a damaged vehicle and starts the repair once it is
 * close enough. The order expires and the move is cancelled after the timeout
 * setting. Must be executed where the unit is local.
 *
 * Arguments:
 * 0: Unit <OBJECT>
 * 1: Vehicle <OBJECT>
 *
 * Return Value:
 * None
 *
 * Example:
 * [_unit, _vehicle] call rtz_repair_fnc_repairVehicle
 *
 * Public: No
 */

params ["_unit", "_vehicle"];

if (!alive _unit || {isNull _vehicle}) exitWith {};

// Supersede any pending order so only the newest one can complete
private _order = (_unit getVariable [QGVAR(order), 0]) + 1;
_unit setVariable [QGVAR(order), _order];

_unit doMove getPosATL _vehicle;

[{
    params ["_unit", "_vehicle", "_order"];
    !alive _unit || {!alive _vehicle} || {_unit getVariable [QGVAR(order), 0] != _order}
        || {_unit distance _vehicle <= REPAIR_DISTANCE}
}, {
    params ["_unit", "_vehicle", "_order"];

    if (!alive _unit || {!alive _vehicle} || {_unit getVariable [QGVAR(order), 0] != _order}) exitWith {};

    // Someone else may have finished the repair while this unit was moving up
    if (damage _vehicle <= REPAIR_THRESHOLD) exitWith {
        _unit doFollow leader _unit;
    };

    [_unit, _vehicle, _order] call FUNC(startRepair);
}, [_unit, _vehicle, _order], GVAR(repairTimeout), {
    params ["_unit", "", "_order"];

    // Cancel the expired move order unless a newer order took over
    if (alive _unit && {_unit getVariable [QGVAR(order), 0] == _order}) then {
        _unit doFollow leader _unit;
    };
}] call CBA_fnc_waitUntilAndExecute;
