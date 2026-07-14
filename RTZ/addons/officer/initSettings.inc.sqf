private _category = [ELSTRING(main,DisplayName), LSTRING(DisplayName)];

// All three are global (server-synced): the server registers the apply handler
// based on the enable flag, and every curator should agree on zone size/behavior.
[
    QGVAR(enable), "CHECKBOX",
    [LSTRING(Enable), LSTRING(Enable_Description)],
    _category,
    true,
    true
] call CBA_fnc_addSetting;

[
    QGVAR(areaRadius), "SLIDER",
    [LSTRING(AreaRadius), LSTRING(AreaRadius_Description)],
    _category,
    [25, 500, 150, 0],
    true
] call CBA_fnc_addSetting;

[
    QGVAR(followOfficer), "CHECKBOX",
    [LSTRING(FollowOfficer), LSTRING(FollowOfficer_Description)],
    _category,
    true,
    true
] call CBA_fnc_addSetting;
