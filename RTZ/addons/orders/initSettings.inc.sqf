private _category = [ELSTRING(main,DisplayName), LSTRING(DisplayName)];

[
    QGVAR(heliHeightStep), "SLIDER",
    [LSTRING(HeliHeightStep), LSTRING(HeliHeightStep_Description)],
    _category,
    [1, 10, 5, 0],
    false // Local
] call CBA_fnc_addSetting;
