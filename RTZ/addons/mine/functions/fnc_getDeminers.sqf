#include "script_component.hpp"
/*
 * Author: Maxim
 * Returns the groups of the selected units able to clear mines: on foot, trained
 * as an engineer or explosive specialist, and carrying a mine detector.
 * Player-led groups are skipped.
 *
 * Groups rather than units, because the order is a group-level waypoint task
 * (FUNC(demine)) — one qualified man makes his whole group capable of running it.
 *
 * Arguments:
 * 0: Selected Objects <ARRAY>
 *
 * Return Value:
 * Capable Groups <ARRAY of GROUP>
 *
 * Example:
 * [_objects] call rtz_mine_fnc_getDeminers
 *
 * Public: No
 */

params [["_objects", [], [[]]]];

private _groups = [];

{
    _groups pushBackUnique (group _x);
} forEach ([_objects, ["engineer", "explosiveSpecialist"], ["MineDetector"]] call EFUNC(common,collectSpecialists));

_groups
