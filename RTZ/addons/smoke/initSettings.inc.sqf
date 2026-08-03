private _category = [ELSTRING(main,DisplayName), LSTRING(DisplayName)];

// Master switch for the context action. Read live by FUNC(canDeploySmoke) on
// the curator's client, so flipping it mid-mission takes effect immediately.
[
    QGVAR(enabled), "CHECKBOX",
    [LSTRING(DeploySmoke), LSTRING(DeploySmoke_Description)],
    _category,
    true,
    true // Global
] call CBA_fnc_addSetting;
