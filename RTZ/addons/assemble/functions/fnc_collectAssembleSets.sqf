#include "script_component.hpp"
/*
 * Author: Maxim
 * Resolves a Zeus selection to the assemble-able static weapons the selected squads
 * carry. Normalizes the selection through EFUNC(common,collectSquads) and returns
 * one entry per group that has a complete disassembled weapon.
 *
 * Arguments:
 * 0: Selected Objects <ARRAY>
 *
 * Return Value:
 * Assemble Sets <ARRAY of ARRAY> - one [gunner, static class, assistant] per group,
 * see FUNC(findAssembleSet). [] when nothing selected can assemble.
 *
 * Example:
 * [_objects] call rtz_assemble_fnc_collectAssembleSets
 *
 * Public: No
 */

params ["_objects"];

(([_objects] call EFUNC(common,collectSquads)) apply {[_x] call FUNC(findAssembleSet)}) select {_x isNotEqualTo []}
