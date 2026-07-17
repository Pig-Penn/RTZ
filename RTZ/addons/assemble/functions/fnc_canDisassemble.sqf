#include "script_component.hpp"
/*
 * Author: Maxim
 * Whether a disassemble order is possible: at least one selected manned static
 * weapon or drone can be packed back into backpacks. Mirror of FUNC(canAssemble).
 *
 * Arguments:
 * 0: Selected Objects <ARRAY>
 *
 * Return Value:
 * Order Possible <BOOL>
 *
 * Example:
 * [_objects] call rtz_assemble_fnc_canDisassemble
 *
 * Public: No
 */

params ["_objects"];

if (!GVAR(enabled)) exitWith {false};

([_objects] call FUNC(collectDisassembleSets)) isNotEqualTo []
