#include "script_component.hpp"
/*
 * Author: Maxim
 * Starts marking spotted mines: refresh PFH, 3D drawing and Zeus map drawing.
 * The map Draw EH is destroyed with the display and needs no cleanup.
 *
 * Arguments:
 * 0: Curator Display <DISPLAY>
 *
 * Return Value:
 * None
 *
 * Example:
 * [_display] call rtz_mine_fnc_start
 *
 * Public: No
 */

params ["_display"];

(_display displayCtrl IDC_RSCDISPLAYCURATOR_MAINMAP) ctrlAddEventHandler ["Draw", {_this call FUNC(drawMap)}];

if (GVAR(pfh) == -1) then {
    GVAR(pfh) = [LINKFUNC(refreshMines), REFRESH_INTERVAL] call CBA_fnc_addPerFrameHandler;
    call FUNC(refreshMines);
};

if (GVAR(draw) == -1) then {
    GVAR(draw) = addMissionEventHandler ["Draw3D", {call FUNC(draw3D)}];
};
