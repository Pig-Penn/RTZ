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

// One switch for both markers, the 3D one and the map one. FUNC(start) reads it to
// decide what to register, so neither draw pass has to test it per frame.
[
    QGVAR(markers), "CHECKBOX",
    [LSTRING(Markers), LSTRING(Markers_Description)],
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
