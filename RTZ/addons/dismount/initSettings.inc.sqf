private _category = [ELSTRING(main,DisplayName), LSTRING(DisplayName)];

[
    QGVAR(enableDismountControl), "CHECKBOX",
    [LSTRING(DismountControl), LSTRING(DismountControl_Description)],
    _category,
    true,
    true
] call CBA_fnc_addSetting;
