private _category = [ELSTRING(main,DisplayName), LSTRING(DisplayName)];

// All three are read LIVE on the curator's client — never by the machine that
// executes the order. The first two are read by the matching context action's
// condition, so flipping one mid-mission takes effect on the next right-click;
// the third (enableRcReset) has no context action and is read by the
// "zen_remoteControlStopped" handler instead, so it takes effect on the next
// remote-control release. Either way the receivers stay registered (an idle CBA
// event handler costs nothing, and gating registration on a setting would break
// exactly the mid-mission enable this buys).
//
// The first two are global; enableRcReset is the one per-client setting here.
//
// Reset, Dismount, and TakeOwnership used to have switches here too; all are
// now always on (see CfgContext.hpp), so their receivers stay registered
// unconditionally like the rest — nothing above ever gated that registration.

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
