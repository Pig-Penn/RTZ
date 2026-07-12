#include "script_component.hpp"
/*
 * Author: Maxim
 * Moves the unit to the mine and disarms it on arrival.
 * Must be executed where the unit is local.
 *
 * Arguments:
 * 0: Unit <OBJECT>
 * 1: Mine <OBJECT>
 *
 * Return Value:
 * None
 *
 * Example:
 * [_unit, _mine] call rtz_mine_fnc_disarmMine
 *
 * Public: No
 */

params ["_unit", "_mine"];

[_unit, getPosATL _mine, DISARM_DISTANCE, {
    params ["_unit", "_mine"];

    if (isNull _mine || {!mineActive _mine}) exitWith {};

    _unit playActionNow "PutDown";

    [{
        params ["_unit", "_mine"];

        if (!alive _unit || {isNull _mine}) exitWith {};

        _unit action ["Deactivate", _unit, _mine];
    }, [_unit, _mine], PUT_DELAY] call CBA_fnc_waitAndExecute;
}, [_unit, _mine]] call FUNC(approach);
