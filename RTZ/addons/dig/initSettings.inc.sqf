private _category = [ELSTRING(main,DisplayName), LSTRING(DisplayName)];

// GLOBAL, not client-local. This component runs on THREE machines — the drawing
// session on the curator's client, FUNC(digCell) wherever each engineer is local,
// FUNC(startDig)/FUNC(buildCell) on the server — and they must agree. A curator
// whose client had the feature on could otherwise send QGVAR(start) to a server that
// never expected to receive it. rtz_airstrike and rtz_path carry the same hazard and
// resolve it the same way.
//
// Default OFF. This one permanently reshapes the terrain and has no undo, so no
// mission should acquire it merely by upgrading the mod.
[
    QGVAR(enabled), "CHECKBOX",
    [LSTRING(Enabled), LSTRING(Enabled_Description)],
    _category,
    false,
    true // Global
] call CBA_fnc_addSetting;

// Seconds one engineer spends on one grid cell. The trench's total cost is this
// times its length in cells, divided among however many engineers were selected.
[
    QGVAR(cellDuration), "SLIDER",
    [LSTRING(CellDuration), LSTRING(CellDuration_Description)],
    _category,
    [5, 300, 45, 0],
    true // Global
] call CBA_fnc_addSetting;

// Read where the digger is local, by EFUNC(common,approach).
[
    QGVAR(digTimeout), "SLIDER",
    [LSTRING(DigTimeout), LSTRING(DigTimeout_Description)],
    _category,
    [10, 600, 90, 0],
    true // Global
] call CBA_fnc_addSetting;

// Server-side registry bound. Digging never stops working when this is reached — the
// OLDEST trench's record is dropped instead, which costs only the ability to fill
// that one back in later.
[
    QGVAR(maxTrenches), "SLIDER",
    [LSTRING(MaxTrenches), LSTRING(MaxTrenches_Description)],
    _category,
    [4, 200, 32, 0],
    true // Global
] call CBA_fnc_addSetting;
