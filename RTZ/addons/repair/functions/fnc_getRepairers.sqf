#include "script_component.hpp"
/*
 * Author: Maxim
 * Returns the selected units able to repair vehicles: on foot, alive, trained
 * as an engineer and carrying a toolkit. Player and player-led units are
 * skipped.
 *
 * Arguments:
 * 0: Selected Objects <ARRAY>
 *
 * Return Value:
 * Capable Units <ARRAY>
 *
 * Example:
 * [_objects] call rtz_repair_fnc_getRepairers
 *
 * Public: No
 */

params [["_objects", [], [[]]]];

private _units = [];

{
    if (
        _x isKindOf "CAManBase" && {alive _x} && {isNull objectParent _x}
        && {!isPlayer _x} && {!isPlayer leader _x}
        && {_x getUnitTrait "engineer"}
        && {"ToolKit" in items _x}
    ) then {
        _units pushBackUnique _x;
    };
} forEach _objects;

_units
