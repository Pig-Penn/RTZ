private _category = [ELSTRING(main,DisplayName), LSTRING(DisplayName)];

[
    QGVAR(enable), "CHECKBOX",
    [LSTRING(Enable), LSTRING(Enable_Description)],
    _category,
    true,
    true
] call CBA_fnc_addSetting;

[
    QGVAR(placementToast), "CHECKBOX",
    [LSTRING(PlacementToast), LSTRING(PlacementToast_Description)],
    _category,
    true,
    false
] call CBA_fnc_addSetting;

// Client-side, unlike Income and Income Interval: those two must agree across
// machines (the readout works the payout out from them locally), but whether a
// curator wants it in their clock bar is a personal preference. Read every tick,
// so toggling it takes effect without backing out of the Zeus interface.
[
    QGVAR(incomeClock), "CHECKBOX",
    [LSTRING(IncomeClock), LSTRING(IncomeClock_Description)],
    _category,
    true,
    false
] call CBA_fnc_addSetting;

// Independent of Enable Economy: hiding still applies with costs disabled.
// Read once per CuratorObjectRegistered call (Zeus interface open/reopen),
// same as every other entry in the cost table — no rejoin needed, but a
// curator already in the interface needs to back out and re-enter to see it
// change.
[
    QGVAR(cleanModuleTree), "CHECKBOX",
    [LSTRING(CleanModuleTree), LSTRING(CleanModuleTree_Description)],
    _category,
    false,
    true // Global
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
    [0, 60, 3, 1],
    true
] call CBA_fnc_addSetting;

// Floor is TICK_INTERVAL, not 0, so the slider cannot offer a spacing the payout
// loop is unable to honour — at 0 every tick is due the moment the last one landed.
// The floor is ENFORCED at the read (INCOME_INTERVAL, script_component.hpp) rather
// than here: a server CBA config can set a value off the slider entirely, so this
// range is honesty for the person moving it, not the guard.
[
    QGVAR(incomeInterval), "SLIDER",
    [LSTRING(IncomeInterval), LSTRING(IncomeInterval_Description)],
    _category,
    [TICK_INTERVAL, 600, 60, 0],
    true
] call CBA_fnc_addSetting;

// No change handler: the refund is no longer an engine coefficient that has to
// be re-applied to every curator, it is read at the moment of the deletion
// (see fnc_refundApply)
[
    QGVAR(deleteRefund), "SLIDER",
    [LSTRING(DeleteRefund), LSTRING(DeleteRefund_Description)],
    _category,
    [0, 100, 50, 0],
    true
] call CBA_fnc_addSetting;
