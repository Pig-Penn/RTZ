private _category = [ELSTRING(main,DisplayName), LSTRING(DisplayName)];

// Global (server-synced): the timeout is read by FUNC(approach) on the machine
// that owns the ordered unit (the server for Zeus AI), not the curator's client
[
    QGVAR(placeTimeout), "SLIDER",
    [LSTRING(PlaceTimeout), LSTRING(PlaceTimeout_Description)],
    _category,
    [10, 600, 60, 0],
    true
] call CBA_fnc_addSetting;

[
    QGVAR(clearHidden), "CHECKBOX",
    [LSTRING(ClearHidden), LSTRING(ClearHidden_Description)],
    _category,
    false,
    false
] call CBA_fnc_addSetting;

[
    QGVAR(mark3D), "CHECKBOX",
    [LSTRING(Mark3D), LSTRING(Mark3D_Description)],
    _category,
    true,
    false
] call CBA_fnc_addSetting;

[
    QGVAR(markMap), "CHECKBOX",
    [LSTRING(MarkMap), LSTRING(MarkMap_Description)],
    _category,
    true,
    false
] call CBA_fnc_addSetting;

[
    QGVAR(markSide), "LIST",
    [LSTRING(MarkSide), LSTRING(MarkSide_Description)],
    _category,
    [
        ["player", "west", "east", "independent", "civilian", "all"],
        [LSTRING(SidePlayer), LSTRING(SideBLUFOR), LSTRING(SideOPFOR), LSTRING(SideIndependent), LSTRING(SideCivilian), LSTRING(SideAll)],
        0
    ],
    false
] call CBA_fnc_addSetting;

[
    QGVAR(maxDistance), "SLIDER",
    [LSTRING(MaxDistance), LSTRING(MaxDistance_Description)],
    _category,
    [50, 5000, 1000, 0],
    false
] call CBA_fnc_addSetting;
