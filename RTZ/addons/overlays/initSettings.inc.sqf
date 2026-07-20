private _category = [ELSTRING(main,DisplayName), LSTRING(DisplayName)];

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
    QGVAR(enableTargetDisplay), "CHECKBOX",
    [LSTRING(DrawTargets), LSTRING(DrawTargets_Description)],
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
