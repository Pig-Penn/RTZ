#include "script_component.hpp"

// Build stamp — logged on every machine so a stale/mismatched client PBO is
// visible in the RPT.
diag_log text format ["[RTZ] overlays postInit — version %1, machine [isServer=%2 hasInterface=%3 clientOwner=%4]",
    QUOTE(VERSION_STR), isServer, hasInterface, clientOwner];

// Both displays are setting-gated, so they are deferred until
// CBA_settingsInitialized — a CLIENT's synced value arrives a frame or more
// after postInit, so a bare read here would race the sync. Each display starts
// the server-side watcher registry + poll loop and, when a client is present,
// its Draw3D handler; the context actions live in CfgContext.hpp.
["CBA_settingsInitialized", {
    if (GVAR(enableDestinationDisplay)) then {
        call FUNC(destinationDisplay);
    };
    if (GVAR(enableTargetDisplay)) then {
        call FUNC(targetDisplay);
    };
}] call CBA_fnc_addEventHandler;
