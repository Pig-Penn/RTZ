private _category = [ELSTRING(main,DisplayName), LSTRING(DisplayName)];

// Global: the apply handler runs where the vehicle is local.
[
    QGVAR(enableDismountControl), "CHECKBOX",
    [LSTRING(DismountControl), LSTRING(DismountControl_Description)],
    _category,
    true,
    true
] call CBA_fnc_addSetting;
