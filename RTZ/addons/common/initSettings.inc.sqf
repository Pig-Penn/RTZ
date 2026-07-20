private _category = [ELSTRING(main,DisplayName), LSTRING(DisplayName)];

[
    QGVAR(enableCleanContextMenu), "CHECKBOX",
    [LSTRING(CleanContextMenu), LSTRING(CleanContextMenu_Description)],
    _category,
    true,
    false // Local
] call CBA_fnc_addSetting;

[
    QGVAR(enableDeploySmoke), "CHECKBOX",
    [LSTRING(DeploySmoke), LSTRING(DeploySmoke_Description)],
    _category,
    true,
    true // Global
] call CBA_fnc_addSetting;

[
    QGVAR(teleportMaxDistance), "SLIDER",
    [LSTRING(TeleportRange), LSTRING(TeleportRange_Description)],
    _category,
    [10, 500, 100, 0],
    true // Global
] call CBA_fnc_addSetting;

[
    QGVAR(teleportCooldown), "SLIDER",
    [LSTRING(TeleportCooldown), LSTRING(TeleportCooldown_Description)],
    _category,
    [0, 60, 10, 0],
    true // Global
] call CBA_fnc_addSetting;

[
    QGVAR(heliHeightStep), "SLIDER",
    [LSTRING(HeliHeightStep), LSTRING(HeliHeightStep_Description)],
    _category,
    [1, 10, 5, 0],
    false // Local
] call CBA_fnc_addSetting;
