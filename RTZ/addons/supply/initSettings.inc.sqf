private _category = [ELSTRING(main,DisplayName), LSTRING(DisplayName)];

// Read on the curator's client, to hide the context menu action
[
    QGVAR(enabled), "CHECKBOX",
    [LSTRING(Enabled), LSTRING(Enabled_Description)],
    _category,
    true,
    true // Global
] call CBA_fnc_addSetting;

// Read on the curator's client when the targets are gathered, and again on the
// server to drop targets that drive off mid-service
[
    QGVAR(serviceRadius), "SLIDER",
    [LSTRING(ServiceRadius), LSTRING(ServiceRadius_Description)],
    _category,
    [5, 100, 30, 0],
    true // Global
] call CBA_fnc_addSetting;

// GVAR(serviceTimeout) and GVAR(serviceInterval) used to sit here. Both are now
// SERVICE_TIMEOUT / SERVICE_TICK in script_component.hpp — they tune the monitor,
// not the service, and the reasoning is written out there.
