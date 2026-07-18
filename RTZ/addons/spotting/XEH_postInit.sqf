#include "script_component.hpp"

// Everything setting-gated is deferred until the CBA_settingsInitialized event.
// Reading a setting straight from postInit is a race: a CLIENT's values arrive
// from the server a frame or more later, so a bare read is nil (and `if (nil)
// then` aborts the whole postInit) while a defensive default silently ignores a
// server-side "disabled" — the feature registers anyway. CBA fires the event one
// frame after postInit, once every GVAR(enable*) holds the server's synced value.
// NOTE: CBA has no CBA_fnc_runAfterSettingsInit — that helper is ACE3/ZEN only
// (ace_common_fnc_/zen_common_fnc_); calling the CBA_ name is a silent nil no-op.
["CBA_settingsInitialized", {
    // Both register handlers + a CBA PFH and return — no scheduled loops.
    if (GVAR(enableSpottingSystem)) then {
        call FUNC(spottingSystem);
    };

    if (GVAR(enableRemoteControlIndicator)) then {
        call FUNC(remoteControlIndicator);
    };
}] call CBA_fnc_addEventHandler;
