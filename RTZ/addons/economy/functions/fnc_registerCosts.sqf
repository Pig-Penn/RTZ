#include "script_component.hpp"
/*
 * Author: Maxim
 * Builds the curator cost table for the CuratorObjectRegistered event.
 * The engine calls this with every CfgVehicles class each time a player
 * enters the curator interface, so costs always follow the current settings.
 *
 * Mission makers can override single classes (in points) with:
 * missionNamespace setVariable [
 *     "rtz_economy_overrides",
 *     createHashMapFromArray [["B_Soldier_F", 2]]
 * ];
 *
 * Arguments:
 * 0: Curator module <OBJECT>
 * 1: Class names <ARRAY of STRING>
 *
 * Return Value:
 * Cost entries, [show, cost] or [show, cost, costWithCrew] per class <ARRAY>
 *
 * Example:
 * [_curator, ["B_Soldier_F"]] call rtz_economy_fnc_registerCosts
 *
 * Public: No
 */

params ["", "_classes"];

// Disabled: keep the full asset tree and make everything free
if (!GVAR(enable)) exitWith {_classes apply {[true, 0]}};

private _categories = GVAR(categories);
private _overrides = GETGVAR(overrides,createHashMap);
private _crewMultiplier = GVAR(crewMultiplier);

// In points, indexed by cost category
private _bases = [
    GVAR(costInfantry),
    GVAR(costStatic),
    GVAR(costCar),
    GVAR(costAPC),
    GVAR(costTracked),
    GVAR(costHelicopter),
    GVAR(costPlane),
    GVAR(costBoat)
];

_classes apply {
    private _index = _categories getOrDefaultCall [_x, {_x call FUNC(categorize)}, true];
    private _cost = (_overrides getOrDefault [_x, if (_index == INDEX_FREE) then {0} else {_bases select _index}]) / POINTS_MAX;

    if (_index == INDEX_FREE || {_index == INDEX_INFANTRY}) then {
        [true, _cost]
    } else {
        [true, _cost, _cost * _crewMultiplier]
    }
}
