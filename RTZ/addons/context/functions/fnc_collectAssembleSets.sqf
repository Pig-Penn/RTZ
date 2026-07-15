#include "script_component.hpp"
/*
 * rtz_fnc_collectAssembleSets
 *
 * Resolves a Zeus selection to the list of assemble-able static weapons the
 * selected squads are carrying. Mirrors FUNC(collectSquads) but returns one
 * entry per group that has a complete disassembled weapon.
 *
 * Parameters:
 *   0: Array — objects from curatorSelected / a ZEN action's selection + hovered
 * Returns: Array of [_gunner, _staticClass, _assistant] sets (see
 *          FUNC(findAssembleSet)); [] when nothing selected can assemble.
 */

params ["_objects"];

(([_objects] call FUNC(collectSquads)) apply { [_x] call FUNC(findAssembleSet) }) select { _x isNotEqualTo [] }
