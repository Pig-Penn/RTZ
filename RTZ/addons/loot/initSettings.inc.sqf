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

// Whether an OCCUPIED slot may be swapped for something better. Filling an EMPTY slot
// is never gated by this - a disarmed unit picks a weapon up either way - so turning
// it off can only ever leave a squad closer to the loadout it was placed with, never
// worse off. Global, because FUNC(lootPlan) is the only reader and it runs on the
// server: a curator's local copy would have no effect at all
[
    QGVAR(upgradeGear), "CHECKBOX",
    [LSTRING(UpgradeGear), LSTRING(UpgradeGear_Description)],
    _category,
    true,
    true
] call CBA_fnc_addSetting;

// Whether the sweep bothers with the specialist items - first aid kits, night vision,
// a medikit for medics, a toolkit for engineers, a mine detector for EOD. Off, the
// order is about weapons and armor only, and a crate holding nothing else stops being
// a destination at all. Global for the same reason as above
[
    QGVAR(takeItems), "CHECKBOX",
    [LSTRING(TakeItems), LSTRING(TakeItems_Description)],
    _category,
    true,
    true
] call CBA_fnc_addSetting;
