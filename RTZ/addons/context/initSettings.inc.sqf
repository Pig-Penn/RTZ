// Scope rule (mirrors rtz_common / rtz_officer): any setting that gates a
// server-side event receiver, or is read on the machine that executes the
// order (server / unit owner), MUST be global (true) — with a client-side
// value the receiver half is registered from the SERVER's copy of the setting
// and a curator flipping it locally gets a context action whose server half
// never existed (or a value the executing machine never sees). Purely local
// UI preferences stay client-side (0).

// Global: the apply handler runs where the vehicle is local.
[
    QGVAR(enableDismountControl),
    "CHECKBOX",
    ["Dismount Control", "Add a context menu action that either forbids or allows units to bail-out of a selected vehicle."],
    ["Real-Time Zeus", "Context Menu"],
    true,
    true
] call CBA_fnc_addSetting;

// Global: hideObjectGlobal/enableSimulationGlobal run on the server.
[
    QGVAR(enableSquadHide),
    "CHECKBOX",
    ["Simulation Control", "Add a context menu action to toggle the simulation and visibility of selected units."],
    ["Real-Time Zeus", "Context Menu"],
    true,
    true
] call CBA_fnc_addSetting;

// Global: the reload handler runs where each group is local.
[
    QGVAR(enableReloadSquad),
    "CHECKBOX",
    ["Reload Squad", "Add a context menu action ordering selected units to reload their current weapon."],
    ["Real-Time Zeus", "Context Menu"],
    true,
    true
] call CBA_fnc_addSetting;

// Global: the assemble/disassemble receivers run on the server.
[
    QGVAR(enableAssembleWeapon),
    "CHECKBOX",
    ["Weapon Assembly", "Add a context menu action to assemble or disassemble an equipped static weapon or drone."],
    ["Real-Time Zeus", "Context Menu"],
    true,
    true
] call CBA_fnc_addSetting;

// Global: read on the SERVER inside the assemble/disassemble errands.
[
    QGVAR(instantAssemble),
    "CHECKBOX",
    ["Instant Assembly", "Assemble and disassemble static weapons instantly: skip the walk to the picked spot and the kneel-and-assemble animation, spawning (or packing) the weapon at once. Drones are already instant either way."],
    ["Real-Time Zeus", "Context Menu"],
    false,
    true
] call CBA_fnc_addSetting;

// Global: the loot sweep runs on the server.
[
    QGVAR(enableLootNearby),
    "CHECKBOX",
    ["Looting", "Add a context menu action ordering selected units to loot nearby bodies, crates, or vehicles."],
    ["Real-Time Zeus", "Context Menu"],
    false,
    true
] call CBA_fnc_addSetting;

// Global: read on the SERVER by the loot sweep (and by the client condition —
// both machines must agree on the radius).
[
    QGVAR(lootRadius),
    "SLIDER",
    ["Loot Radius", "How far around a squad's leader the Loot Nearby action searches for lootable bodies, crates and vehicles (meters)."],
    ["Real-Time Zeus", "Context Menu"],
    [10, 100, 50, 0],
    true
] call CBA_fnc_addSetting;

// Global: the destination poll loop runs on the server.
[
    QGVAR(enableDestinationDisplay),
    "CHECKBOX",
    ["Draw Destinations", "Add a context menu action to show where a selected squad's units are moving."],
    ["Real-Time Zeus", "Context Menu"],
    true,
    true
] call CBA_fnc_addSetting;

// Client-side: pure per-curator visual preference.
[
    QGVAR(destGrowWithSpeed),
    "CHECKBOX",
    ["Destination Icon Scaling", "Scale the destination move icon with the unit's speed — larger the faster it moves (the LAMBS debug look). When off, the icon stays a fixed size."],
    ["Real-Time Zeus", "Context Menu"],
    false,
    0
] call CBA_fnc_addSetting;

// Global: the target poll loop runs on the server.
[
    QGVAR(enableTargetDisplay),
    "CHECKBOX",
    ["Draw Targets", "Add a context menu action to show what a selected squad's units are aiming at (a line to where the AI believes its target is)."],
    ["Real-Time Zeus", "Context Menu"],
    true,
    true
] call CBA_fnc_addSetting;

// Client-side: the gear dialog is a purely local UI action.
[
    QGVAR(enableUnitInventory),
    "CHECKBOX",
    ["Unit Inventory", "Add a keybind to arrange the inventory of the selected unit or vehicle."],
    ["Real-Time Zeus", "Context Menu"],
    true,
    0
] call CBA_fnc_addSetting;
