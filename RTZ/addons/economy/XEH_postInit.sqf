#include "script_component.hpp"

// Cost tables are queried on the machine entering the curator interface,
// points and income are managed by the server
if (!isServer && {!hasInterface}) exitWith {};

["CBA_settingsInitialized", {
    // Curator modules can be created mid-mission (e.g. ZEN's Add Zeus module),
    // so the income tick doubles as lazy detection of new modules
    [{
        if (!GVAR(enable)) exitWith {};

        {_x call FUNC(initCurator)} forEach allCurators;

        if (isServer && {GVAR(income) > 0}) then {
            private _points = GVAR(income) * TICK_INTERVAL / (60 * POINTS_MAX);
            {_x addCuratorPoints _points} forEach allCurators;
        };
    }, TICK_INTERVAL] call CBA_fnc_addPerFrameHandler;
}] call CBA_fnc_addEventHandler;

if (!hasInterface) exitWith {};

// Cost feedback while the curator is choosing something to place
["zen_curatorDisplayLoaded", {
    GVAR(toastClass) = "";
    GVAR(toastPFH) = [LINKFUNC(placementToast), TOAST_INTERVAL] call CBA_fnc_addPerFrameHandler;
}] call CBA_fnc_addEventHandler;

["zen_curatorDisplayUnloaded", {
    if (GVAR(toastPFH) == -1) exitWith {};

    [GVAR(toastPFH)] call CBA_fnc_removePerFrameHandler;
    GVAR(toastPFH) = -1;
}] call CBA_fnc_addEventHandler;
