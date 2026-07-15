private _category = [ELSTRING(main,DisplayName), LSTRING(DisplayName)];

// All global (server-synced): timeout and duration are read by the repair
// routine on the machine that owns the engineer (the server for Zeus AI), and
// the toolkit requirement decides which orders are possible at all — every
// machine must agree on the rules
[
    QGVAR(repairTimeout), "SLIDER",
    [LSTRING(RepairTimeout), LSTRING(RepairTimeout_Description)],
    _category,
    [10, 600, 60, 0],
    true
] call CBA_fnc_addSetting;

[
    QGVAR(repairDuration), "SLIDER",
    [LSTRING(RepairDuration), LSTRING(RepairDuration_Description)],
    _category,
    [1, 120, 20, 0],
    true
] call CBA_fnc_addSetting;

[
    QGVAR(requireToolkit), "CHECKBOX",
    [LSTRING(RequireToolkit), LSTRING(RequireToolkit_Description)],
    _category,
    true,
    true
] call CBA_fnc_addSetting;
