private _category = [ELSTRING(main,DisplayName), LSTRING(DisplayName)];

[
    QGVAR(enabled), "CHECKBOX",
    [LSTRING(Enabled), LSTRING(Enabled_Description)],
    _category,
    true,
    false // Local
] call CBA_fnc_addSetting;

[
    QGVAR(instant), "CHECKBOX",
    [LSTRING(Instant), LSTRING(Instant_Description)],
    _category,
    false,
    true // Global
] call CBA_fnc_addSetting;
