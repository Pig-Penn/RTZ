#include "script_component.hpp"
/*
 * Author: Maxim
 * Initializes a spawned infantry unit. Skills only matter on the machine
 * that owns the AI, and applying is deferred a frame so loadout scripts
 * and other InitPost handlers finish first.
 *
 * Arguments:
 * 0: Unit <OBJECT>
 *
 * Return Value:
 * None
 *
 * Example:
 * [_unit] call rtz_common_fnc_initMan
 *
 * Public: No
 */

params ["_unit"];

if (!local _unit || {isPlayer _unit}) exitWith {};

[FUNC(applySkill), _unit] call CBA_fnc_execNextFrame;
