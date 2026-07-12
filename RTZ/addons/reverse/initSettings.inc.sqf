private _category = [ELSTRING(main,DisplayName), LSTRING(DisplayName)];

[
    QGVAR(timeout), "SLIDER",
    [LSTRING(Timeout), LSTRING(Timeout_Description)],
    _category,
    [5, 300, 60, 0],
    false
] call CBA_fnc_addSetting;
