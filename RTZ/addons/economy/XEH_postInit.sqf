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
        // were configured with.
        //
        // SERVER ONLY. This used to run on every interface machine as well, which
        // meant a getVariable per curator module every TICK_INTERVAL on every
        // client for the whole mission, to catch an event that happens a handful
        // of times. The client half of FUNC(initCurator) only attaches a
        // CuratorObjectRegistered handler, and that handler only ever fires "on
        // the machine of the player entering the curator interface" — so the
        // client is served exactly as well by doing it when the curator display
        // actually opens (see the zen_curatorDisplayLoaded handler below).
        if (isServer) then {
            {_x call FUNC(initCurator)} forEach allCurators;
        };

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

    // Client-side half of the lazy curator detection the income tick used to do
    // for everyone (see above). FUNC(initCurator) is idempotent, and this is the
    // moment the handler it attaches starts to matter — a module created
    // mid-mission is picked up the next time anyone opens Zeus.
    {_x call FUNC(initCurator)} forEach allCurators;

    {
        (_display displayCtrl _x) ctrlAddEventHandler ["TreeSelChanged", LINKFUNC(placementToast)];
    } forEach IDCS_CREATE_TREES;
}] call CBA_fnc_addEventHandler;
