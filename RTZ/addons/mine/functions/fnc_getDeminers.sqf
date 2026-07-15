#include "script_component.hpp"
/*
 * Author: Maxim
 * Returns the groups of the selected units able to clear mines: on foot,
 * trained as an engineer or explosive specialist, and carrying a mine
 * detector. Player-led groups are skipped.
 *
 * Arguments:
 * 0: Selected Objects <ARRAY>
 *
 * Return Value:
 * Capable Groups <ARRAY>
 *
 * Example:
 * [_objects] call rtz_mine_fnc_getDeminers
 *
 * Public: No
 */

params [["_objects", [], [[]]]];

private _groups = [];

{
    if (
        _x isKindOf "CAManBase" && {alive _x} && {isNull objectParent _x}
        && {!isPlayer _x} && {!isPlayer leader _x}
        && {_x getUnitTrait "engineer" || {_x getUnitTrait "explosiveSpecialist"}}
        && {"MineDetector" in items _x}
    ) then {
        _groups pushBackUnique group _x;
    };
} forEach _objects;

_groups
