#include "script_component.hpp"
/*
 * Author: Maxim
 * Returns the placement cost of a CfgVehicles class in points (POINTS_MAX
 * equals a full resource bar), following the same precedence as the curator
 * cost table: mission override -> built-in table -> category default.
 *
 * Arguments:
 * 0: Class name <STRING>
 *
 * Return Value:
 * Cost in points <NUMBER>
 *
 * Example:
 * ["B_Soldier_F"] call rtz_economy_fnc_getCost
 *
 * Public: No
 */

params ["_class"];

if (!GVAR(enable)) exitWith {0};

private _index = GVAR(categories) getOrDefaultCall [_class, {_class call FUNC(categorize)}, true];

// Precedence: mission override -> built-in table (lowercased keys) -> category default
private _base = GVAR(defaultCosts) getOrDefault [toLowerANSI _class, if (_index == INDEX_FREE) then {0} else {GVAR(baseCosts) select _index}];
GETGVAR(overrides,createHashMap) getOrDefault [_class, _base]
