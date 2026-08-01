private _category = [ELSTRING(main,DisplayName), LSTRING(DisplayName)];

// Neither master switch needs a mission restart. The stream machinery is
// registered unconditionally on every machine (see XEH_postInit) and is idle
// while nothing is subscribed, so these only gate the context ACTION — read live
// by its condition — and FUNC(streamClient) watches CBA_SettingChanged to shut a
// running overlay down if its switch goes off mid-mission.

[
    QGVAR(enableDestinationDisplay), "CHECKBOX",
    [LSTRING(DrawDestinations), LSTRING(DrawDestinations_Description)],
    _category,
    true,
    true // Global
] call CBA_fnc_addSetting;

[
    QGVAR(enableTargetDisplay), "CHECKBOX",
    [LSTRING(DrawTargets), LSTRING(DrawTargets_Description)],
    _category,
    true,
    true // Global
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
