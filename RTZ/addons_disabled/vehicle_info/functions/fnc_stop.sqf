#include "script_component.hpp"
/*
 * Author: Maxim
 * Removes the Draw3D event handler.
 *
 * Arguments:
 * None
 *
 * Return Value:
 * None
 *
 * Example:
 * [] call rtz_vehicle_info_fnc_stop
 *
 * Public: No
 */

if (GVAR(draw) != -1) then {
    removeMissionEventHandler ["Draw3D", GVAR(draw)];
    GVAR(draw) = -1;
};
