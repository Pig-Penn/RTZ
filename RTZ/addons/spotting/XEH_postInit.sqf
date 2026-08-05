#include "script_component.hpp"

// Everything setting-gated is deferred until the CBA_settingsInitialized event.
// Reading a setting straight from postInit is a race: a CLIENT's values arrive
// from the server a frame or more later, so a bare read is nil (and `if (nil)
// then` aborts the whole postInit) while a defensive default silently ignores a
// server-side "disabled" — the feature registers anyway. CBA fires the event one
// frame after postInit, once every GVAR(enable*) holds the server's synced value.
// NOTE: CBA has no CBA_fnc_runAfterSettingsInit — that helper is ACE3/ZEN only
// (ace_common_fnc_/zen_common_fnc_); calling the CBA_ name is a silent nil no-op.
//
// Both starts route through FUNC(startSystems), which owns the enable checks and
// the once-per-machine guards. Settings-initialized is the FIRST sample, not the
// only one: neither setting is forced or restart-only, so this block used to
// sample each exactly once, a frame after postInit, and an admin switching
// spotting on mid-mission got nothing at all — no detection loop, no client
// stores, no renderers, and nothing in the log to say why. The CBA_SettingChanged
// handler below is what makes the switch mean something.
["CBA_settingsInitialized", {
    // Both register handlers + a CBA PFH and return — no scheduled loops.
    call FUNC(startSystems);
}] call CBA_fnc_addEventHandler;

// Bring a system up when its master setting is switched on mid-mission.
// FUNC(startSystems) re-reads both settings and refuses to start either twice,
// so it does not matter which of the two fired, or how often.
["CBA_SettingChanged", {
    params ["_name"];
    // Lowercased: CBA_SettingChanged is not guaranteed to report the name in the
    // case it was registered with.
    if !((toLower _name) in [toLower QGVAR(enableSpottingSystem), toLower QGVAR(enableRemoteControlIndicator)]) exitWith {};

    call FUNC(startSystems);
}] call CBA_fnc_addEventHandler;
