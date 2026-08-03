#include "script_component.hpp"
/*
 * Author: Maxim
 * Starts marking spotted mines: the refresh PFH, the 3D drawing and the Zeus map
 * drawing. Called when the curator display opens, and again whenever one of the
 * two marker settings is toggled mid-mission (see XEH_postInit).
 *
 * Each piece is registered only when the setting that feeds it is actually ON, and
 * torn down again when it is turned off — rather than registering everything and
 * testing the settings inside a handler that then runs every single frame for
 * nothing. With both markers off the component costs exactly zero.
 *
 * The map Draw handler is attached to a control of the curator display, so it dies
 * with the display; the stored control is only kept so a mid-mission toggle can
 * detach it early.
 *
 * These markers stay a plain local overlay rather than moving onto rtz_core's
 * stream engine: that engine is selection-driven and server-polled, while
 * detectedMines is readable on the client and these icons must show regardless of
 * what the curator has selected. Routing them through it would buy nothing and
 * cost a server round trip. (The frame loop below is a different thing entirely,
 * and this component does use that.)
 *
 * Arguments:
 * 0: Curator Display <DISPLAY> — omitted on a setting-change refresh
 *
 * Return Value:
 * None
 *
 * Example:
 * [_display] call rtz_mine_fnc_start
 *
 * Public: No
 */

params [["_display", displayNull]];

private _wanted = GVAR(mark3D) || {GVAR(markMap)};

// The cache feeds both markers, so it is kept alive for either
if (_wanted) then {
    if (GVAR(pfh) == -1) then {
        GVAR(pfh) = [LINKFUNC(refreshMines), REFRESH_INTERVAL] call CBA_fnc_addPerFrameHandler;
        call FUNC(refreshMines);
    };
} else {
    if (GVAR(pfh) != -1) then {
        [GVAR(pfh)] call CBA_fnc_removePerFrameHandler;
        GVAR(pfh) = -1;
        GVAR(mines) = [];
    };
};

// Registration with rtz_core's shared frame loop, not a Draw3D handler of our
// own — registering and unregistering is what makes the marker free while it is
// switched off, exactly as adding/removing the handler used to be.
if (GVAR(mark3D)) then {
    [QGVAR(mines3D), ELINKFUNC(mine,draw3D), RENDER_WORLD, 60] call EFUNC(core,registerRenderer);
} else {
    [QGVAR(mines3D), RENDER_WORLD] call EFUNC(core,unregisterRenderer);
};

if (!isNull _display) then {
    GVAR(mapCtrl) = _display displayCtrl IDC_RSCDISPLAYCURATOR_MAINMAP;
};

if (isNull GVAR(mapCtrl)) exitWith {};

// Added and removed by id rather than cleared wholesale — ctrlRemoveAllEventHandlers
// would take ZEN's own Draw handlers on the same map with it
if (GVAR(markMap)) then {
    if (GVAR(mapEH) == -1) then {
        GVAR(mapEH) = GVAR(mapCtrl) ctrlAddEventHandler ["Draw", {_this call FUNC(drawMap)}];
    };
} else {
    if (GVAR(mapEH) != -1) then {
        GVAR(mapCtrl) ctrlRemoveEventHandler ["Draw", GVAR(mapEH)];
        GVAR(mapEH) = -1;
    };
};
