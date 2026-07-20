private _category = [ELSTRING(main,DisplayName), LSTRING(DisplayName)];

[
    QGVAR(enableSquadHide), "CHECKBOX",
    [LSTRING(SquadHide), LSTRING(SquadHide_Description)],
    _category,
    true,
    true // Global
] call CBA_fnc_addSetting;

[
    QGVAR(enableReloadSquad), "CHECKBOX",
    [LSTRING(ReloadSquad), LSTRING(ReloadSquad_Description)],
    _category,
    true,
    true // Global
] call CBA_fnc_addSetting;
