private _category = [ELSTRING(main,DisplayName), LSTRING(DisplayName)];

// Read on the curator's client, to hide the context menu action
[
    QGVAR(enabled), "CHECKBOX",
    [LSTRING(Enabled), LSTRING(Enabled_Description)],
    _category,
    true,
    true // Global
] call CBA_fnc_addSetting;

// Gates the supply-lines overlay's context action, read live by its condition.
// Needs no mission restart: the stream machinery is registered unconditionally
// (see XEH_postInit) and idles while nothing is subscribed, and the engine's
// CBA_SettingChanged watchdog shuts a running overlay down if this goes off.
[
    QGVAR(enableSupplyDisplay), "CHECKBOX",
    [LSTRING(SupplyDisplay), LSTRING(SupplyDisplay_Description)],
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

// Read on the server when the order starts
[
    QGVAR(serviceDuration), "SLIDER",
    [LSTRING(ServiceDuration), LSTRING(ServiceDuration_Description)],
    _category,
    [1, 300, 30, 0],
    true // Global
] call CBA_fnc_addSetting;

// Read on the server when the order starts. Progress is clock-interpolated, so
// this changes how often it is written, not how fast vehicles are serviced.
[
    QGVAR(serviceInterval), "SLIDER",
    [LSTRING(ServiceInterval), LSTRING(ServiceInterval_Description)],
    _category,
    [0.5, 5, 1, 1],
    true // Global
] call CBA_fnc_addSetting;
