private _category = [ELSTRING(main,DisplayName), LSTRING(DisplayName)];

// Master switch - hides the Loot Nearby context menu action entirely. Client-side:
// it is read by FUNC(canLoot) on the curator's own machine and only gates what he
// can order. The server-side receiver registers unconditionally (see XEH_postInit),
// so a curator flipping this locally can never end up with an action whose server
// half was never registered
[
    QGVAR(enabled), "CHECKBOX",
    [LSTRING(Enabled), LSTRING(Enabled_Description)],
    _category,
    false,
    false
] call CBA_fnc_addSetting;

// Global (server-synced): read by the curator's client in FUNC(canLoot) AND by the
// server in FUNC(lootSquads) - both machines must agree on the radius, or the action
// offers a sweep that finds nothing once it runs
[
    QGVAR(radius), "SLIDER",
    [LSTRING(Radius), LSTRING(Radius_Description)],
    _category,
    [10, 100, 50, 0],
    true
] call CBA_fnc_addSetting;
