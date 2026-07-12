#include "script_component.hpp"
/*
 * Author: Maxim
 * Moves the unit to the given position and plants the mine on arrival.
 * Must be executed where the unit is local.
 *
 * Arguments:
 * 0: Unit <OBJECT>
 * 1: Position AGL <ARRAY>
 * 2: Magazine <STRING>
 *
 * Return Value:
 * None
 *
 * Example:
 * [_unit, _pos, "ATMine_Range_Mag"] call rtz_mine_fnc_placeMine
 *
 * Public: No
 */

params ["_unit", "_pos", "_magazine"];

[_unit, _pos, PLACE_DISTANCE, {
    params ["_unit", "_magazine"];

    if (_magazine in magazines _unit) then {
        [_unit, _magazine] call FUNC(plantMine);
    };
}, [_unit, _magazine]] call FUNC(approach);
