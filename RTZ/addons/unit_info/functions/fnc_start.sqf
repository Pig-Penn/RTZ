#include "script_component.hpp"
/*
 * Author: Maxim
 * Starts the Draw3D EH that draws info above tracked units.
 *
 * Arguments:
 * None
 *
 * Return Value:
 * None
 *
 * Example:
 * [] call rtz_unit_info_fnc_start
 *
 * Public: No
 */

if (GVAR(draw) != -1 || {GVAR(units) isEqualTo []}) exitWith {};

GVAR(draw) = addMissionEventHandler ["Draw3D", {call FUNC(draw3D)}];
