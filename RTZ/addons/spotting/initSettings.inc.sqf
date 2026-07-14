private _category = [ELSTRING(main,DisplayName), LSTRING(DisplayName)];

// The enable flags and the interval are global (server-synced): the detection
// loops run on the server, so every machine must agree on whether a system is
// active. Chevron names are a per-client cosmetic preference.
[
    QGVAR(enableSpottingSystem), "CHECKBOX",
    [LSTRING(EnableSpotting), LSTRING(EnableSpotting_Description)],
    _category,
    true,
    true
] call CBA_fnc_addSetting;

[
    QGVAR(enableRemoteControlIndicator), "CHECKBOX",
    [LSTRING(EnableRC), LSTRING(EnableRC_Description)],
    _category,
    true,
    true
] call CBA_fnc_addSetting;

[
    QGVAR(spotCheckInterval), "SLIDER",
    [LSTRING(CheckInterval), LSTRING(CheckInterval_Description)],
    _category,
    [1, 10, 3, 0],
    true
] call CBA_fnc_addSetting;

[
    QGVAR(chevronNames), "CHECKBOX",
    [LSTRING(ChevronNames), LSTRING(ChevronNames_Description)],
    _category,
    false,
    false
] call CBA_fnc_addSetting;
