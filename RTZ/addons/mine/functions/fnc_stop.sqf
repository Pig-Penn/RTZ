#include "script_component.hpp"
/*
 * Author: Maxim
 * Stops marking spotted mines and clears the mine cache.
 *
 * Arguments:
 * None
 *
 * Return Value:
 * None
 *
 * Example:
 * [] call rtz_mine_fnc_stop
 *
 * Public: No
 */

if (GVAR(pfh) != -1) then {
    [GVAR(pfh)] call CBA_fnc_removePerFrameHandler;
    GVAR(pfh) = -1;
};

if (GVAR(draw) != -1) then {
    removeMissionEventHandler ["Draw3D", GVAR(draw)];
    GVAR(draw) = -1;
};

GVAR(mines) = [];
