#include "script_component.hpp"
/*
 * Author: Maxim
 * Moves a unit to a position and runs the statement once it is close enough.
 * The order expires and the move is cancelled after the timeout setting.
 * Must be executed where the unit is local.
 *
 * Arguments:
 * 0: Unit <OBJECT>
 * 1: Position AGL <ARRAY>
 * 2: Completion Distance <NUMBER>
 * 3: Statement <CODE>
 * 4: Statement Arguments <ARRAY> (default: [])
 *
 * Return Value:
 * None
 *
 * Example:
 * [_unit, _pos, 2, {hint "arrived"}] call rtz_mine_fnc_approach
 *
 * Public: No
 */

params ["_unit", "_pos", "_distance", "_statement", ["_args", []]];

// Supersede any pending order so only the newest one can complete
private _order = (_unit getVariable [QGVAR(order), 0]) + 1;
_unit setVariable [QGVAR(order), _order];

_unit doMove _pos;

[{
    params ["_unit", "_pos", "_distance", "", "", "_order"];
    !alive _unit || {_unit getVariable [QGVAR(order), 0] != _order} || {_unit distance2D _pos <= _distance}
}, {
    params ["_unit", "", "", "_statement", "_args", "_order"];

    if (alive _unit && {_unit getVariable [QGVAR(order), 0] == _order}) then {
        _args call _statement;
    };
}, [_unit, _pos, _distance, _statement, _args, _order], GVAR(placeTimeout), {
    params ["_unit", "", "", "", "", "_order"];

    // Cancel the expired move order unless a newer order took over
    if (alive _unit && {_unit getVariable [QGVAR(order), 0] == _order}) then {
        _unit doMove getPosATL _unit;
    };
}] call CBA_fnc_waitUntilAndExecute;
