private _category = [ELSTRING(main,DisplayName), LSTRING(DisplayName)];

// Master switch — hides the Repair Vehicle context menu action entirely.
// Client-side: only gates what the local Zeus player can order.
[
    QGVAR(enabled), "CHECKBOX",
    [LSTRING(Enabled), LSTRING(Enabled_Description)],
    _category,
    true,
    false
] call CBA_fnc_addSetting;

// Global (server-synced): timeout and duration are read by the repair
// routine on the machine that owns the engineer (the server for Zeus AI) —
// every machine must agree on the rules
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
