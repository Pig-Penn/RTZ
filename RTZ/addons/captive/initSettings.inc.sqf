private _category = [ELSTRING(main,DisplayName), LSTRING(DisplayName)];

// Master switch for the whole surrender / capture system. While off the context
// action never registers and the capture watch never starts (see XEH_postInit).
[
    QGVAR(enableSurrender), "CHECKBOX",
    [LSTRING(Surrender), LSTRING(Surrender_Description)],
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
    [0, 1800, 300, 0],
    true
] call CBA_fnc_addSetting;

// Enemy proximity capture: a surrendered unit with a live enemy inside the
// radius is taken prisoner — permanently surrendered, control transfers to the
// capturing side's curators, and both curators are awarded points.
[
    QGVAR(enableCapture), "CHECKBOX",
    [LSTRING(Capture), LSTRING(Capture_Description)],
    _category,
    false,
    true
] call CBA_fnc_addSetting;

[
    QGVAR(captureRadius), "SLIDER",
    [LSTRING(CaptureRadius), LSTRING(CaptureRadius_Description)],
    _category,
    [5, 200, 50, 0],
    true
] call CBA_fnc_addSetting;
