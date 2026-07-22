private _category = [ELSTRING(main,DisplayName), LSTRING(DisplayName)];

[
    QGVAR(enableSpottingSystem), "CHECKBOX",
    [LSTRING(EnableSpotting), LSTRING(EnableSpotting_Description)],
    _category,
    true,
    true // Global
] call CBA_fnc_addSetting;

[
    QGVAR(chevronNames), "CHECKBOX",
    [LSTRING(ChevronNames), LSTRING(ChevronNames_Description)],
    _category,
    false,
    false // Local
] call CBA_fnc_addSetting;

[
    QGVAR(enableRemoteControlIndicator), "CHECKBOX",
    [LSTRING(EnableRC), LSTRING(EnableRC_Description)],
    _category,
    true,
    true // Global
] call CBA_fnc_addSetting;

[
    QGVAR(spotCheckInterval), "SLIDER",
    [LSTRING(CheckInterval), LSTRING(CheckInterval_Description)],
    _category,
    [1, 10, 3, 0],
    true // Global
] call CBA_fnc_addSetting;

[
    QGVAR(rcCheckInterval), "SLIDER",
    [LSTRING(RCCheckInterval), LSTRING(RCCheckInterval_Description)],
    _category,
    [1, 10, 3, 0],
    true // Global
] call CBA_fnc_addSetting;
