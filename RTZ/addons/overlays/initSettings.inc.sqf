private _category = [ELSTRING(main,DisplayName), LSTRING(DisplayName)];

// The enable settings are only read once at CBA_settingsInitialized (they gate
// the display loops in XEH_postInit), so changing them needs a mission restart.
[
    QGVAR(enableDestinationDisplay), "CHECKBOX",
    [LSTRING(DrawDestinations), LSTRING(DrawDestinations_Description)],
    _category,
    true,
    true, // Global
    {},
    true // Needs mission restart
] call CBA_fnc_addSetting;

[
    QGVAR(destGrowWithSpeed), "CHECKBOX",
    [LSTRING(DestinationIconScaling), LSTRING(DestinationIconScaling_Description)],
    _category,
    false,
    0 // Client
] call CBA_fnc_addSetting;

[
    QGVAR(enableTargetDisplay), "CHECKBOX",
    [LSTRING(DrawTargets), LSTRING(DrawTargets_Description)],
    _category,
    true,
    true, // Global
    {},
    true // Needs mission restart
] call CBA_fnc_addSetting;
