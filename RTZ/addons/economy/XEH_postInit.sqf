#include "script_component.hpp"

// Cost tables are queried on the machine entering the curator interface,
// points and income are managed by the server
if (!isServer && {!hasInterface}) exitWith {};

["CBA_settingsInitialized", {
    // Curator modules can be created mid-mission (e.g. ZEN's Add Zeus module),
    // so the income tick doubles as lazy detection of new modules
    [{
        // Curators are set up even with the economy disabled, so that disabled
        // reliably means free rather than whatever the mission's Zeus modules
        // were configured with
        {_x call FUNC(initCurator)} forEach allCurators;

        if (isServer && {GVAR(enable)} && {GVAR(income) > 0}) then {
            private _points = GVAR(income) * TICK_INTERVAL / 60;
            {[_x, _points] call FUNC(addPoints)} forEach allCurators;
        };
    }, TICK_INTERVAL] call CBA_fnc_addPerFrameHandler;
}] call CBA_fnc_addEventHandler;

if (!hasInterface) exitWith {};

// Cost feedback while the curator is choosing something to place. The display
// and its controls are recreated on every open, so these handlers go with them
["zen_curatorDisplayLoaded", {
    params ["_display"];

    {
        (_display displayCtrl _x) ctrlAddEventHandler ["TreeSelChanged", LINKFUNC(placementToast)];
    } forEach IDCS_CREATE_TREES;
}] call CBA_fnc_addEventHandler;
