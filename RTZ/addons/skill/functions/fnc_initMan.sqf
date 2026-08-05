#include "script_component.hpp"
/*
 * Author: Maxim
 * Initializes a spawned infantry unit. Skills only matter on the machine
 * that owns the AI, and applying is deferred a frame so loadout scripts
 * and other InitPost handlers finish first.
 *
 * This runs from a CAManBase InitPost class event handler, i.e. once for every
 * man spawned from any source, so it resolves the skill table entry HERE and
 * bails before queueing anything when the class has none — which is the
 * overwhelming majority of classes. A hashmap probe per spawned unit is far
 * cheaper than a frame-deferred call per spawned unit, and it is the
 * difference that shows during a mass spawn. The resolved value rides along to
 * FUNC(applySkill) so the lookup happens exactly once.
 *
 * Arguments:
 * 0: Unit <OBJECT>
 *
 * Return Value:
 * None
 *
 * Example:
 * [_unit] call rtz_skill_fnc_initMan
 *
 * Public: No
 */

params ["_unit"];

if (!local _unit || { isPlayer _unit }) exitWith {};

private _skill = GVAR(defaultSkills) getOrDefault [toLowerANSI typeOf _unit, SKILL_NONE];
if (_skill == SKILL_NONE) exitWith {};

[FUNC(applySkill), [_unit, _skill]] call CBA_fnc_execNextFrame;
