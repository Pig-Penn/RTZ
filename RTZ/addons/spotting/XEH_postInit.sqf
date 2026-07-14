#include "script_component.hpp"

// Build stamp — logged on every machine so a stale/mismatched client PBO is visible
// in the RPT. This is a separate PBO from main; it can be stale independently.
diag_log text format ["[RTZ] spotting postInit — version %1, machine [isServer=%2 hasInterface=%3 clientOwner=%4]",
    QUOTE(VERSION_STR), isServer, hasInterface, clientOwner];

// Everything setting-gated is deferred until the CBA_settingsInitialized event.
// Reading a setting straight from postInit is a race: a CLIENT's values arrive
// from the server a frame or more later, so a bare read is nil (and `if (nil)
// then` aborts the whole postInit) while a defensive default silently ignores a
// server-side "disabled" — the feature registers anyway. CBA fires the event one
// frame after postInit, once every GVAR(enable*) holds the server's synced value.
// NOTE: CBA has no CBA_fnc_runAfterSettingsInit — that helper is ACE3/ZEN only
// (ace_common_fnc_/zen_common_fnc_); calling the CBA_ name is a silent nil no-op.
["CBA_settingsInitialized", {
    if (GVAR(enableSpottingSystem)) then {
        [] spawn FUNC(spottingSystem);
    };

    // No scheduled loop inside — registers handlers + a CBA PFH and returns.
    if (GVAR(enableRemoteControlIndicator)) then {
        call FUNC(remoteControlIndicator);
    };
}] call CBA_fnc_addEventHandler;
