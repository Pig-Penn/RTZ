#include "script_component.hpp"
/*
 * Author: Maxim
 * Applies the built-in overall skill level for the unit's classname,
 * if the class has an entry in the default skill table.
 *
 * Arguments:
 * 0: Unit <OBJECT>
 *
 * Return Value:
 * None
 *
 * Example:
 * [_unit] call rtz_common_fnc_applySkill
 *
 * Public: No
 */

params ["_unit"];

if (!alive _unit) exitWith {};

private _skill = GVAR(defaultSkills) getOrDefault [toLowerANSI typeOf _unit, SKILL_NONE];
if (_skill == SKILL_NONE) exitWith {};

// Overall skill: sets every sub-skill to this value at once
_unit setSkill _skill;
