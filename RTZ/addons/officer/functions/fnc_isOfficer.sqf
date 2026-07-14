#include "script_component.hpp"
/*
 * Author: Maxim
 * Single source of truth for the "is this an officer?" heuristic: a man whose
 * class name contains "officer" (case-insensitive) — covers vanilla
 * B_/O_/I_officer_F and the guerilla variants. The verdict is memoised per
 * class in GVAR(classCache), so the string scan runs once per class instead
 * of once per call. Widen the computation below for custom command classes.
 *
 * Arguments:
 * 0: Unit <OBJECT>
 *
 * Return Value:
 * Is Officer <BOOLEAN>
 *
 * Example:
 * [_unit] call rtz_officer_fnc_isOfficer
 *
 * Public: No
 */

params ["_unit"];

// isKindOf is false for objNull, so no separate null check is needed
if !(_unit isKindOf "CAManBase") exitWith {false};

private _class = typeOf _unit;
GVAR(classCache) getOrDefaultCall [_class, {(toLowerANSI _class) find "officer" >= 0}, true]
