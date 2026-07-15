private _category = [ELSTRING(main,DisplayName), LSTRING(DisplayName)];

// Global (server-synced): the timeout is read by FUNC(reverseTo) on the machine
// that owns the vehicle (the server for Zeus AI), not the curator's client
[
    QGVAR(timeout), "SLIDER",
    [LSTRING(Timeout), LSTRING(Timeout_Description)],
    _category,
    [5, 300, 60, 0],
    true
] call CBA_fnc_addSetting;
