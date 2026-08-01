#include "script_component.hpp"
/*
 * Author: Maxim
 * Returns the selected units able to repair vehicles: on foot, alive, trained as
 * an engineer and carrying a toolkit. Player and player-led units are skipped.
 *
 * Shared by the context menu condition (FUNC(canRepair)) and its statement
 * (FUNC(orderRepair)) so the entry can never offer an order that resolves to
 * nothing. The filtering itself is EFUNC(common,collectSpecialists), which also
 * expands a selected vehicle to its crew — pick a squad's truck and the engineer
 * riding in it still qualifies for the order.
 *
 * Arguments:
 * 0: Selected Objects <ARRAY>
 *
 * Return Value:
 * Capable Units <ARRAY of OBJECT>
 *
 * Example:
 * [_objects] call rtz_repair_fnc_getRepairers
 *
 * Public: No
 */

params [["_objects", [], [[]]]];

[_objects, ["engineer"], ["ToolKit"]] call EFUNC(common,collectSpecialists)
