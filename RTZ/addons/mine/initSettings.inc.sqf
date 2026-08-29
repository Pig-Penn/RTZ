private _category = [ELSTRING(main,DisplayName), LSTRING(DisplayName)];

[
    QGVAR(enabled), "CHECKBOX",
    [LSTRING(Enabled), LSTRING(Enabled_Description)],
    _category,
    false,
    true // Global
] call CBA_fnc_addSetting;

[
    QGVAR(placeTimeout), "SLIDER",
    [LSTRING(PlaceTimeout), LSTRING(PlaceTimeout_Description)],
    _category,
    [10, 600, 60, 0],
    true // Global
] call CBA_fnc_addSetting;

[
    QGVAR(mark3D), "CHECKBOX",
    [LSTRING(Mark3D), LSTRING(Mark3D_Description)],
    _category,
    true,
    false // Local
] call CBA_fnc_addSetting;

[
    QGVAR(markMap), "CHECKBOX",
    [LSTRING(MarkMap), LSTRING(MarkMap_Description)],
    _category,
    true,
    false // Local
] call CBA_fnc_addSetting;

[
    QGVAR(maxDistance), "SLIDER",
    [LSTRING(MaxDistance), LSTRING(MaxDistance_Description)],
    _category,
    [100, 1000, 300, 0],
    false // Local
] call CBA_fnc_addSetting;
