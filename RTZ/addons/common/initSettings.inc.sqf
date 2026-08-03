private _category = [ELSTRING(main,DisplayName), LSTRING(DisplayName)];

[
    QGVAR(enableCleanContextMenu), "CHECKBOX",
    [LSTRING(CleanContextMenu), LSTRING(CleanContextMenu_Description)],
    _category,
    true,
    false // Local
] call CBA_fnc_addSetting;
