private _category = [ELSTRING(main,DisplayName), LSTRING(DisplayName)];

// Global: the destination poll loop runs on the server.
[
    QGVAR(enableDestinationDisplay), "CHECKBOX",
    [LSTRING(DrawDestinations), LSTRING(DrawDestinations_Description)],
    _category,
    true,
    true
] call CBA_fnc_addSetting;

// Client-side: pure per-curator visual preference.
[
    QGVAR(destGrowWithSpeed), "CHECKBOX",
    [LSTRING(DestinationIconScaling), LSTRING(DestinationIconScaling_Description)],
    _category,
    false,
    0
] call CBA_fnc_addSetting;

// Global: the target poll loop runs on the server.
[
    QGVAR(enableTargetDisplay), "CHECKBOX",
    [LSTRING(DrawTargets), LSTRING(DrawTargets_Description)],
    _category,
    true,
    true
] call CBA_fnc_addSetting;
