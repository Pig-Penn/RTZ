private _category = [ELSTRING(main,DisplayName), LSTRING(DisplayName)];

// All global (server-synced): these gate and bound what a curator's keybinds
// may do, so every machine must agree on the limits
[
    QGVAR(enableUnitTeleport), "CHECKBOX",
    [LSTRING(EnableUnitTeleport), LSTRING(EnableUnitTeleport_Description)],
    _category,
    true,
    true
] call CBA_fnc_addSetting;

[
    QGVAR(teleportMaxDistance), "SLIDER",
    [LSTRING(TeleportRange), LSTRING(TeleportRange_Description)],
    _category,
    [10, 500, 100, 0],
    true
] call CBA_fnc_addSetting;

[
    QGVAR(teleportCooldown), "SLIDER",
    [LSTRING(TeleportCooldown), LSTRING(TeleportCooldown_Description)],
    _category,
    [0, 60, 10, 0],
    true
] call CBA_fnc_addSetting;

[
    QGVAR(heliHeightStep), "SLIDER",
    [LSTRING(HeliHeightStep), LSTRING(HeliHeightStep_Description)],
    _category,
    [1, 10, 5, 0],
    true
] call CBA_fnc_addSetting;
