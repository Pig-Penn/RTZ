private _category = [ELSTRING(main,DisplayName), LSTRING(DisplayName)];

// All settings are global (server-synced): the server registers the apply
// handlers based on the enable flags, and every curator should agree on zone
// size/behavior.
[
    QGVAR(enable), "CHECKBOX",
    [LSTRING(Enable), LSTRING(Enable_Description)],
    _category,
    true,
    true
] call CBA_fnc_addSetting;

[
    QGVAR(areaRadius), "SLIDER",
    [LSTRING(AreaRadius), LSTRING(AreaRadius_Description)],
    _category,
    [50, 300, 100, 0],
    true
] call CBA_fnc_addSetting;

[
    QGVAR(auraEnable), "CHECKBOX",
    [LSTRING(AuraEnable), LSTRING(AuraEnable_Description)],
    _category,
    false,
    true
] call CBA_fnc_addSetting;

[
    QGVAR(auraRadius), "SLIDER",
    [LSTRING(AuraRadius), LSTRING(AuraRadius_Description)],
    _category,
    [50, 300, 100, 0],
    true
] call CBA_fnc_addSetting;
