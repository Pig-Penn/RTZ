#include "script_component.hpp"

// Build stamp — logged on every machine so a stale/mismatched client PBO is
// visible in the RPT. A separate PBO from main; it can be stale independently.
diag_log text format ["[RTZ] dismount postInit — version %1, machine [isServer=%2 hasInterface=%3 clientOwner=%4]",
    QUOTE(VERSION_STR), isServer, hasInterface, clientOwner];

// Setting-gated: deferred until CBA_settingsInitialized so the synced value has
// landed (a bare read from postInit is a frame too early on a client).
// FUNC(unloadInCombat) registers the QGVAR(applyUnloadFlags) receiver on every
// machine and, on interface machines, the RTZ_Control toggle action.
["CBA_settingsInitialized", {
    if (GVAR(enableDismountControl)) then {
        [] spawn FUNC(unloadInCombat);
    };
}] call CBA_fnc_addEventHandler;
