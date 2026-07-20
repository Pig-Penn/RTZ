private _category = [ELSTRING(main,DisplayName), LSTRING(DisplayName)];

[
    QGVAR(enabled), "CHECKBOX",
    [LSTRING(Enabled), LSTRING(Enabled_Description)],
    _category,
    false,
    true // Global
] call CBA_fnc_addSetting;

[
    QGVAR(repairTimeout), "SLIDER",
    [LSTRING(RepairTimeout), LSTRING(RepairTimeout_Description)],
    _category,
    [10, 600, 60, 0],
    true // Global
] call CBA_fnc_addSetting;

[
    QGVAR(repairDuration), "SLIDER",
    [LSTRING(RepairDuration), LSTRING(RepairDuration_Description)],
    _category,
    [1, 120, 20, 0],
    true // Global
] call CBA_fnc_addSetting;
