#include "script_component.hpp"
/*
 * Author: Maxim
 * Resolves a Zeus selection to the assemble-able static weapons the selected squads
 * carry. Normalizes the selection through EFUNC(common,collectSquads) and returns
 * every complete disassembled weapon each group holds - a weapons squad carrying two
 * HMG sets contributes both.
 *
 * Arguments:
 * 0: Selected Objects <ARRAY>
 *
 * Return Value:
 * Assemble Sets <ARRAY of ARRAY> - one [gunner, static class, assistant] per
 * complete set, see FUNC(findAssembleSets). [] when nothing selected can assemble.
 *
 * Example:
 * [_objects] call rtz_assemble_fnc_collectAssembleSets
 *
 * Public: No
 */

params ["_objects"];

private _sets = [];

{
    _sets append ([_x] call FUNC(findAssembleSets));
} forEach ([_objects] call EFUNC(common,collectSquads));

_sets
