private _category = [ELSTRING(main,DisplayName), LSTRING(DisplayName)];

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
