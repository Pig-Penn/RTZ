#include "script_component.hpp"
/*
 * Author: Maxim
 * Whether an assemble order is possible: at least one selected squad carries a
 * complete disassembled static weapon. Drives the visibility of the context menu
 * action, which ZEN evaluates on right-click rather than per frame.
 *
 * Arguments:
 * 0: Selected Objects <ARRAY>
 *
 * Return Value:
 * Order Possible <BOOL>
 *
 * Example:
 * [_objects] call rtz_assemble_fnc_canAssemble
 *
 * Public: No
 */

params ["_objects"];

if (!GVAR(enabled)) exitWith {false};

([_objects] call FUNC(collectAssembleSets)) isNotEqualTo []
