private _category = [ELSTRING(main,DisplayName), LSTRING(DisplayName)];

// Global (server-synced): read on every curator's client by the attribute,
// context-action and heal-module gates. Mission makers set the policy — a
// curator must not be able to switch his own restrictions off.
[
    QGVAR(enabled), "CHECKBOX",
    [LSTRING(Enabled), LSTRING(Enabled_Description)],
    _category,
    false,
    true
] call CBA_fnc_addSetting;
