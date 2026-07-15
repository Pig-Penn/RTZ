private _category = [ELSTRING(main,DisplayName), LSTRING(DisplayName)];

// Master switch — off by default: the selection addon's Dog Tags replace this
// legacy per-unit overlay. Enable it to get the old context-menu toggle back.
[
    QGVAR(enabled), "CHECKBOX",
    [LSTRING(Enabled), LSTRING(Enabled_Description)],
    _category,
    false,
    false
] call CBA_fnc_addSetting;

[
    QGVAR(maxDistance), "SLIDER",
    [LSTRING(MaxDistance), LSTRING(MaxDistance_Description)],
    _category,
    [50, 5000, 1000, 0],
    false
] call CBA_fnc_addSetting;

[
    QGVAR(scale), "SLIDER",
    [LSTRING(Scale), LSTRING(Scale_Description)],
    _category,
    [0.5, 3, 1, 1],
    false
] call CBA_fnc_addSetting;

[
    QGVAR(showName), "CHECKBOX",
    [LSTRING(ShowName), LSTRING(ShowName_Description)],
    _category,
    true,
    false
] call CBA_fnc_addSetting;

[
    QGVAR(showGroup), "CHECKBOX",
    [LSTRING(ShowGroup), LSTRING(ShowGroup_Description)],
    _category,
    false,
    false
] call CBA_fnc_addSetting;

[
    QGVAR(showHealth), "CHECKBOX",
    [LSTRING(ShowHealth), LSTRING(ShowHealth_Description)],
    _category,
    true,
    false
] call CBA_fnc_addSetting;

[
    QGVAR(showAmmo), "CHECKBOX",
    [LSTRING(ShowAmmo), LSTRING(ShowAmmo_Description)],
    _category,
    true,
    false
] call CBA_fnc_addSetting;

[
    QGVAR(showDistance), "CHECKBOX",
    [LSTRING(ShowDistance), LSTRING(ShowDistance_Description)],
    _category,
    false,
    false
] call CBA_fnc_addSetting;

[
    QGVAR(showVehicle), "CHECKBOX",
    [LSTRING(ShowVehicle), LSTRING(ShowVehicle_Description)],
    _category,
    true,
    false
] call CBA_fnc_addSetting;

[
    QGVAR(showCommand), "CHECKBOX",
    [LSTRING(ShowCommand), LSTRING(ShowCommand_Description)],
    _category,
    false,
    false
] call CBA_fnc_addSetting;

[
    QGVAR(showUnitState), "CHECKBOX",
    [LSTRING(ShowUnitState), LSTRING(ShowUnitState_Description)],
    _category,
    false,
    false
] call CBA_fnc_addSetting;

[
    QGVAR(showTask), "CHECKBOX",
    [LSTRING(ShowTask), LSTRING(ShowTask_Description)],
    _category,
    false,
    false
] call CBA_fnc_addSetting;

[
    QGVAR(showTactic), "CHECKBOX",
    [LSTRING(ShowTactic), LSTRING(ShowTactic_Description)],
    _category,
    false,
    false
] call CBA_fnc_addSetting;

[
    QGVAR(useSideColor), "CHECKBOX",
    [LSTRING(UseSideColor), LSTRING(UseSideColor_Description)],
    _category,
    true,
    false
] call CBA_fnc_addSetting;

[
    QGVAR(removeOnDeath), "CHECKBOX",
    [LSTRING(RemoveOnDeath), LSTRING(RemoveOnDeath_Description)],
    _category,
    false,
    false
] call CBA_fnc_addSetting;
