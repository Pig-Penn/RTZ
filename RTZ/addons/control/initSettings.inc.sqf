private _category = [ELSTRING(main,DisplayName), LSTRING(DisplayName)];

// All five are read LIVE on the curator's client, by the matching context
// action's condition — never by the machine that executes the order. Flipping
// one mid-mission therefore takes effect on the next right-click, and the
// receivers stay registered either way (an idle CBA event handler costs
// nothing, and gating registration on a setting would break exactly the
// mid-mission enable this buys).

[
    QGVAR(enableSquadHide), "CHECKBOX",
    [LSTRING(SquadHide), LSTRING(SquadHide_Description)],
    _category,
    true,
    true // Global
] call CBA_fnc_addSetting;

[
    QGVAR(enableReloadSquad), "CHECKBOX",
    [LSTRING(ReloadSquad), LSTRING(ReloadSquad_Description)],
    _category,
    true,
    true // Global
] call CBA_fnc_addSetting;

// Reset is the destructive one — it rebuilds each group from scratch and
// discards every order and per-group flag hung on the old one (see
// FUNC(resetApply)) — so it gets a switch like the rest.
[
    QGVAR(enableReset), "CHECKBOX",
    [LSTRING(Reset), LSTRING(Reset_Description)],
    _category,
    true,
    true // Global
] call CBA_fnc_addSetting;

[
    QGVAR(enableTakeOwnership), "CHECKBOX",
    [LSTRING(TakeOwnership), LSTRING(TakeOwnership_Description)],
    _category,
    true,
    true // Global
] call CBA_fnc_addSetting;

[
    QGVAR(enableDismount), "CHECKBOX",
    [LSTRING(Dismount), LSTRING(Dismount_Description)],
    _category,
    true,
    true // Global
] call CBA_fnc_addSetting;
