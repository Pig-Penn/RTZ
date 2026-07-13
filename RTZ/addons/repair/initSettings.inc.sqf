private _category = [ELSTRING(main,DisplayName), LSTRING(DisplayName)];

[
    QGVAR(repairTimeout), "SLIDER",
    [LSTRING(RepairTimeout), LSTRING(RepairTimeout_Description)],
    _category,
    [10, 600, 60, 0],
    false
] call CBA_fnc_addSetting;

[
    QGVAR(repairDuration), "SLIDER",
    [LSTRING(RepairDuration), LSTRING(RepairDuration_Description)],
    _category,
    [1, 120, 20, 0],
    false
] call CBA_fnc_addSetting;

[
    QGVAR(requireToolkit), "CHECKBOX",
    [LSTRING(RequireToolkit), LSTRING(RequireToolkit_Description)],
    _category,
    true,
    false
] call CBA_fnc_addSetting;
