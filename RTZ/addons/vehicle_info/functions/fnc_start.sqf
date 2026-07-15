#include "script_component.hpp"
/*
 * Author: Maxim
 * Starts the Draw3D EH that draws info above tracked vehicles.
 *
 * Arguments:
 * None
 *
 * Return Value:
 * None
 *
 * Example:
 * [] call rtz_vehicle_info_fnc_start
 *
 * Public: No
 */

// Master switch check covers vehicles tracked before the setting was turned
// off: their draw loop simply never restarts on the next Zeus session.
if (!GETGVAR(enabled,false) || {GVAR(draw) != -1} || {GVAR(vehicles) isEqualTo []}) exitWith {};

GVAR(draw) = addMissionEventHandler ["Draw3D", {call FUNC(draw3D)}];
