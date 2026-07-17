private _category = [ELSTRING(main,DisplayName), LSTRING(DisplayName)];

// Global: hideObjectGlobal/enableSimulationGlobal run on the server.
[
    QGVAR(enableSquadHide), "CHECKBOX",
    [LSTRING(SquadHide), LSTRING(SquadHide_Description)],
    _category,
    true,
    true
] call CBA_fnc_addSetting;

// Global: the reload handler runs where each group is local.
[
    QGVAR(enableReloadSquad), "CHECKBOX",
    [LSTRING(ReloadSquad), LSTRING(ReloadSquad_Description)],
    _category,
    true,
    true
] call CBA_fnc_addSetting;
