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
 * "B_Soldier_F" call rtz_economy_fnc_getCost
 *
 * Public: Yes
 */

params ["_class"];

if (!GVAR(enable)) exitWith {0};

private _lower = toLowerANSI _class;

// Mission overrides beat everything. Matched case-insensitively as well as
// exactly, so a hand-typed override table cannot miss on casing alone
private _cost = GVAR(overrides) getOrDefault [_class, GVAR(overrides) getOrDefault [_lower, -1]];
if (_cost >= 0) exitWith {_cost};

// The built-in table is keyed lowercase for the same reason
_cost = GVAR(defaultCosts) getOrDefault [_lower, -1];
if (_cost >= 0) exitWith {_cost};

// Only classes both tables miss pay for the inheritance walk, and only once:
// this runs for every CfgVehicles class each time a player opens the interface
private _index = GVAR(categories) getOrDefaultCall [_class, {_this call FUNC(categorize)}, true];
if (_index == INDEX_FREE) exitWith {0};

GVAR(baseCosts) select _index
