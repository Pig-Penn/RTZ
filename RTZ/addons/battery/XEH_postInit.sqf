#include "script_component.hpp"

// Receiver for FUNC(discardTarget), registered on EVERY machine and outside the
// settings gate below. Both are deliberate: the fire mission target can end up local
// to a machine with no curator and no interface on it (initModule rehomes module
// logics from the server), and the counter-battery setting this file otherwise waits
// on has nothing to do with the fire mission action, which carries its own.
[QGVAR(discardTarget), {
    params ["_target"];

    deleteVehicle _target;
}] call CBA_fnc_addEventHandler;

// Everything below here is setting-gated, so it is deferred to CBA_settingsInitialized.
// Reading a setting straight from postInit is a race: a CLIENT's values arrive from
// the server a frame or more later, so a bare read is nil — and `if (nil) then`
// aborts the whole postInit silently (Gotchas §2/§4) — while a defensive default
// quietly ignores a server-side "disabled" and starts the system anyway.
//
// NOTE: there is no CBA_fnc_runAfterSettingsInit. That helper is ACE3/ZEN only;
// calling the CBA_ name is a silent nil no-op.
["CBA_settingsInitialized", {
    call FUNC(startSystem);
}] call CBA_fnc_addEventHandler;

// Settings-initialized is the FIRST sample, not the only one. QGVAR(enabled) is
// neither forced nor restart-only, so without this an admin switching
// counter-battery on mid-mission would get nothing at all and nothing in the log to
// say why. FUNC(startSystem) both starts and STOPS — it removes the mission event
// handler and detaches the map Draw handler when the setting goes off — so it does
// not matter which way the switch moved.
//
// QGVAR(showIncoming) is deliberately absent from this list: it is read inside
// FUNC(drawMap)'s incoming pass, which only runs while the overlay is already
// attached, so flipping it needs no re-registration.
["CBA_SettingChanged", {
    params ["_name"];

    // Lowercased: CBA_SettingChanged is not guaranteed to report the name in the
    // case it was registered with.
    if ((toLower _name) != (toLower QGVAR(enabled))) exitWith {};

    call FUNC(startSystem);
}] call CBA_fnc_addEventHandler;
