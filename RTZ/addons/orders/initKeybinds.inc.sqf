private _category = ELSTRING(main,DisplayName);

// Every handler checks its own preconditions (Zeus open, search box not
// focused, relevant selection) and returns false to pass the key through, so
// the binds are registered unconditionally. Settings are read at press time.

// Zeus-map camera teleport. Plain MMB can't be used — the map control eats
// the middle-click before any script sees it (see fnc_curatorMapTeleport).
[_category, QGVAR(curatorMapTeleport), [LSTRING(CameraToCursor), LSTRING(CameraToCursor_Description)],
    {call FUNC(curatorMapTeleport)}, {}, [0x21, [false, false, false]]] call CBA_fnc_addKeybind; // Default: F

// Unit stance keybinds — after a ZEN dev-branch feature (zen-mod/ZEN#795) that
// never shipped in a release. That branch bound one key per stance; these two
// step the selection up and down the ladder instead, so the curator raises or
// lowers men without having to know which rung they are on. The arrow cluster
// is free while Zeus is open — the camera moves on WASD.
[_category, QGVAR(switchStanceUp), [LSTRING(StanceUp), LSTRING(StanceUp_Description)],
    {["RAISE"] call FUNC(switchStance)}, {}, [0xC8, [false, false, false]]] call CBA_fnc_addKeybind; // Default: Up Arrow

[_category, QGVAR(switchStanceDown), [LSTRING(StanceDown), LSTRING(StanceDown_Description)],
    {["LOWER"] call FUNC(switchStance)}, {}, [0xD0, [false, false, false]]] call CBA_fnc_addKeybind; // Default: Down Arrow

[_category, QGVAR(switchStanceAuto), [LSTRING(StanceAuto), LSTRING(StanceAuto_Description)],
    {["AUTO"] call FUNC(switchStance)}, {}, [0xCD, [false, false, false]]] call CBA_fnc_addKeybind; // Default: Right Arrow

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
    // `[] call`, NOT bare `call`: CBA hands the keybind handler the Zeus display,
    // and the function's `params` would then try to read it as the unit.
    {[] call FUNC(openUnitInventory)}, {}, [0x17, [false, false, false]]] call CBA_fnc_addKeybind; // Default: I
