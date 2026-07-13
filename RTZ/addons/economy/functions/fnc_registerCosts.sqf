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
private _defaults = GVAR(defaultCosts);

// In points, indexed by cost category
private _bases = [
    COST_INFANTRY,
    COST_STATIC,
    COST_CAR,
    COST_APC,
    COST_TRACKED,
    COST_HELICOPTER,
    COST_PLANE,
    COST_BOAT,
    COST_TRUCK,
    COST_OFFICER
];

_classes apply {
    private _index = _categories getOrDefaultCall [_x, {_x call FUNC(categorize)}, true];
    // Precedence: mission override -> built-in table -> category default
    private _base = _defaults getOrDefault [_x, if (_index == INDEX_FREE) then {0} else {_bases select _index}];
    private _cost = (_overrides getOrDefault [_x, _base]) / POINTS_MAX;

    // A vehicle costs the same placed with or without its crew, so a single
    // cost (charged for both cases by the engine) is enough for every class
    [true, _cost]
}
