private _category = [ELSTRING(main,DisplayName), LSTRING(DisplayName)];

[
    QGVAR(maxDistance), "SLIDER",
    [LSTRING(MaxDistance), LSTRING(MaxDistance_Description)],
    _category,
    [50, 5000, 1500, 0],
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
    QGVAR(showFuel), "CHECKBOX",
    [LSTRING(ShowFuel), LSTRING(ShowFuel_Description)],
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
    QGVAR(showCrew), "CHECKBOX",
    [LSTRING(ShowCrew), LSTRING(ShowCrew_Description)],
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
    QGVAR(showSpeed), "CHECKBOX",
    [LSTRING(ShowSpeed), LSTRING(ShowSpeed_Description)],
    _category,
    false,
    false
] call CBA_fnc_addSetting;

[
    QGVAR(showDamage), "CHECKBOX",
    [LSTRING(ShowDamage), LSTRING(ShowDamage_Description)],
    _category,
    true,
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
    QGVAR(removeOnDestroyed), "CHECKBOX",
    [LSTRING(RemoveOnDestroyed), LSTRING(RemoveOnDestroyed_Description)],
    _category,
    false,
    false
] call CBA_fnc_addSetting;
