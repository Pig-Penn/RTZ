private _category = [ELSTRING(main,DisplayName), LSTRING(DisplayName)];

[
    QGVAR(timeout), "SLIDER",
    [LSTRING(Timeout), LSTRING(Timeout_Description)],
    _category,
    [5, 60, 10, 0],
    true // Global
] call CBA_fnc_addSetting;
