private _category = [ELSTRING(main,DisplayName), LSTRING(DisplayName)];

// All six are read LIVE on the curator's client — never by the machine that
// executes the order. The first five are read by the matching context action's
// condition, so flipping one mid-mission takes effect on the next right-click;
// the sixth (enableRcReset) has no context action and is read by the
// "zen_remoteControlStopped" handler instead, so it takes effect on the next
// remote-control release. Either way the receivers stay registered (an idle CBA
// event handler costs nothing, and gating registration on a setting would break
// exactly the mid-mission enable this buys).
//
// The first five are global; enableRcReset is the one per-client setting here.

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

// Per-curator, NOT global: this is a personal preference about the curator's own
// remote-control releases, not a mission rule, and it is read on the very client
// that just released the unit. 0 is CBA's documented default — "1: all clients
// share the same setting, 2: setting can't be overwritten (optional, default: 0)"
// — spelled out rather than omitted so the difference from the five above is
// visible at the call site.
[
    QGVAR(enableRcReset), "CHECKBOX",
    [LSTRING(RcReset), LSTRING(RcReset_Description)],
    _category,
    true,
    0 // Per-client
] call CBA_fnc_addSetting;
