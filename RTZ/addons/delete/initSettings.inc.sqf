private _category = [ELSTRING(main,DisplayName), LSTRING(DisplayName)];

// Read live on the curator's client — by the context action's condition and by
// the keybind handler at press time — so flipping it mid-mission takes effect
// without a rejoin. The server never reads it: once an order is sent, the
// receiver trusts it.
[
    QGVAR(enabled), "CHECKBOX",
    [LSTRING(Enabled), LSTRING(Enabled_Description)],
    _category,
    true,
    true // Global
] call CBA_fnc_addSetting;
