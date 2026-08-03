private _category = ELSTRING(main,DisplayName);

// Every handler checks its own preconditions (Zeus open, search box not
// focused, relevant selection) and returns false to pass the key through, so
// the binds are registered unconditionally. Settings are read at press time.

// Zeus-map camera teleport. Plain MMB can't be used — the map control eats
// the middle-click before any script sees it (see fnc_curatorMapTeleport).
[_category, QGVAR(curatorMapTeleport), [LSTRING(CameraToCursor), LSTRING(CameraToCursor_Description)],
    {call FUNC(curatorMapTeleport)}, {}, [0x21, [false, false, false]]] call CBA_fnc_addKeybind; // Default: F

// Selected-unit teleport to cursor. Client-side handler: curatorSelected and
// the cursor are UI-local, and setPos has global effects so no server
// round-trip is needed (see fnc_teleportToCursor).
[_category, QGVAR(teleportToCursor), [LSTRING(TeleportToCursor), LSTRING(TeleportToCursor_Description)],
    {call FUNC(teleportToCursor)}, {}, [0x14, [true, false, false]]] call CBA_fnc_addKeybind; // Default: Shift + T

// Unit stance keybinds — a ZEN dev-branch feature (zen-mod/ZEN#795) that
// never shipped in a release. Unbound by default, matching that branch.
[_category, QGVAR(switchStanceUp), [LSTRING(StanceUp), LSTRING(StanceUp_Description)],
    {["UP"] call FUNC(switchStance)}, {}, [0, [false, false, false]]] call CBA_fnc_addKeybind; // Default: Unbound

[_category, QGVAR(switchStanceMiddle), [LSTRING(StanceMiddle), LSTRING(StanceMiddle_Description)],
    {["MIDDLE"] call FUNC(switchStance)}, {}, [0, [false, false, false]]] call CBA_fnc_addKeybind; // Default: Unbound

[_category, QGVAR(switchStanceDown), [LSTRING(StanceDown), LSTRING(StanceDown_Description)],
    {["DOWN"] call FUNC(switchStance)}, {}, [0, [false, false, false]]] call CBA_fnc_addKeybind; // Default: Unbound

[_category, QGVAR(switchStanceAuto), [LSTRING(StanceAuto), LSTRING(StanceAuto_Description)],
    {["AUTO"] call FUNC(switchStance)}, {}, [0, [false, false, false]]] call CBA_fnc_addKeybind; // Default: Unbound

// Helicopter fly-height keybinds
[_category, QGVAR(heliHeightUp), [LSTRING(HeliHeightUp), LSTRING(HeliHeightUp_Description)],
    {[1] call FUNC(flyHeight)}, {}, [0xC9, [false, false, false]]] call CBA_fnc_addKeybind; // Default: PageUp

[_category, QGVAR(heliHeightDown), [LSTRING(HeliHeightDown), LSTRING(HeliHeightDown_Description)],
    {[-1] call FUNC(flyHeight)}, {}, [0xD1, [false, false, false]]] call CBA_fnc_addKeybind; // Default: PageDown

// Flip the selected AI groups between forced Hold Fire and standard Open Fire
[_category, QGVAR(toggleCombatMode), [LSTRING(ToggleCombatMode), LSTRING(ToggleCombatMode_Description)],
    {call FUNC(toggleCombatMode)}, {}, [0x23, [true, false, false]]] call CBA_fnc_addKeybind; // Default: Shift + H

// Open selected unit's inventory. Client-only: the gear dialog is a UI action,
// and the engine's networked inventory sync carries the item transfers even when
// the unit/container is remote (see fnc_openUnitInventory).
[_category, QGVAR(openUnitInventory), [LSTRING(OpenUnitInventory), LSTRING(OpenUnitInventory_Description)],
    {call FUNC(openUnitInventory)}, {}, [0x17, [false, false, false]]] call CBA_fnc_addKeybind; // Default: I
