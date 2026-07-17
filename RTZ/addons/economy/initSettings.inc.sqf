private _category = [ELSTRING(main,DisplayName), LSTRING(DisplayName)];

[
    QGVAR(enable), "CHECKBOX",
    [LSTRING(Enable), LSTRING(Enable_Description)],
    _category,
    true,
    true
] call CBA_fnc_addSetting;

[
    QGVAR(income), "SLIDER",
    [LSTRING(Income), LSTRING(Income_Description)],
    _category,
    [0, 60, 5, 1],
    true
] call CBA_fnc_addSetting;

[
    QGVAR(deleteRefund), "SLIDER",
    [LSTRING(DeleteRefund), LSTRING(DeleteRefund_Description)],
    _category,
    [0, 100, 50, 0],
    true,
    {
        if (!isServer) exitWith {};

        {
            _x call FUNC(applyCoefs);
        } forEach (allCurators select {_x getVariable [QGVAR(initialized), false]});
    }
] call CBA_fnc_addSetting;
