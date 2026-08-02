private _category = [ELSTRING(main,DisplayName), LSTRING(DisplayName)];

// One master switch for the whole component. Surrender and the enemy-proximity
// capture that follows from it were two separate checkboxes; they are one
// feature. Capture only ever acts on units this system surrendered, and a
// surrender whose prisoners can never be taken is a pose generator — neither
// half is meaningful alone, so neither gets its own toggle.
//
// Read LIVE, at the moment it matters: the context action's condition tests it
// on every menu open and FUNC(registerSurrender) tests it before admitting a
// unit to the capture watch. Nothing installs itself behind this flag (see
// XEH_postInit), so switching it on or off mid-mission takes effect at once and
// the setting does not demand a restart.
[
    QGVAR(enabled), "CHECKBOX",
    [LSTRING(Enabled), LSTRING(Enabled_Description)],
    _category,
    false,
    true
] call CBA_fnc_addSetting;

// Seconds after surrendering during which a unit CANNOT be ordered to stand
// down — surrender is a commitment, not a free invisibility toggle.
[
    QGVAR(standDownLockTime), "SLIDER",
    [LSTRING(StandDownLockTime), LSTRING(StandDownLockTime_Description)],
    _category,
    [0, 600, 180, 0],
    true
] call CBA_fnc_addSetting;

// How close an enemy must come to take a surrendered unit prisoner.
[
    QGVAR(captureRadius), "SLIDER",
    [LSTRING(CaptureRadius), LSTRING(CaptureRadius_Description)],
    _category,
    [5, 100, 50, 0],
    true
] call CBA_fnc_addSetting;
