private _category = [ELSTRING(main,DisplayName), LSTRING(DisplayName)];

[
    QGVAR(enable), "CHECKBOX",
    [LSTRING(Enable), LSTRING(Enable_Description)],
    _category,
    true,
    true
] call CBA_fnc_addSetting;

[
    QGVAR(startingPoints), "SLIDER",
    [LSTRING(StartingPoints), LSTRING(StartingPoints_Description)],
    _category,
    [0, 100, 100, 0],
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

[
    QGVAR(costInfantry), "SLIDER",
    [LSTRING(CostInfantry), LSTRING(CostInfantry_Description)],
    _category,
    [0, 50, 1, 1],
    true
] call CBA_fnc_addSetting;

[
    QGVAR(costStatic), "SLIDER",
    [LSTRING(CostStatic), LSTRING(CostStatic_Description)],
    _category,
    [0, 50, 5, 1],
    true
] call CBA_fnc_addSetting;

[
    QGVAR(costCar), "SLIDER",
    [LSTRING(CostCar), LSTRING(CostCar_Description)],
    _category,
    [0, 50, 6, 1],
    true
] call CBA_fnc_addSetting;

[
    QGVAR(costAPC), "SLIDER",
    [LSTRING(CostAPC), LSTRING(CostAPC_Description)],
    _category,
    [0, 50, 15, 1],
    true
] call CBA_fnc_addSetting;

[
    QGVAR(costTracked), "SLIDER",
    [LSTRING(CostTracked), LSTRING(CostTracked_Description)],
    _category,
    [0, 50, 25, 1],
    true
] call CBA_fnc_addSetting;

[
    QGVAR(costHelicopter), "SLIDER",
    [LSTRING(CostHelicopter), LSTRING(CostHelicopter_Description)],
    _category,
    [0, 50, 20, 1],
    true
] call CBA_fnc_addSetting;

[
    QGVAR(costPlane), "SLIDER",
    [LSTRING(CostPlane), LSTRING(CostPlane_Description)],
    _category,
    [0, 50, 30, 1],
    true
] call CBA_fnc_addSetting;

[
    QGVAR(costBoat), "SLIDER",
    [LSTRING(CostBoat), LSTRING(CostBoat_Description)],
    _category,
    [0, 50, 10, 1],
    true
] call CBA_fnc_addSetting;
