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

// One cadence for both server poll loops (destinations + targets). Read live
// each tick.
[
    QGVAR(pollInterval), "SLIDER",
    [LSTRING(PollInterval), LSTRING(PollInterval_Description)],
    _category,
    [0.5, 10, 2, 1],
    true // Global
] call CBA_fnc_addSetting;
