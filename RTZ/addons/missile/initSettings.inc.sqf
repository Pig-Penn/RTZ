private _category = [ELSTRING(main,DisplayName), LSTRING(DisplayName)];

// Read on two machines — wherever the threatened unit is local (the detection gate
// in FUNC(detectIncoming)) and again on the server before the fan-out — so it has
// to be global. Turning it off stops the reports at the source, which is what makes
// the whole component free while it is switched off.
[
    QGVAR(enabled), "CHECKBOX",
    [LSTRING(Enabled), LSTRING(Enabled_Description)],
    _category,
    true,
    true // Global
] call CBA_fnc_addSetting;

// One switch for both markers, the 3D one and the map one. Read on the curator's
// client only, by FUNC(start) when it decides which handlers to register — which
// is why neither draw pass has to test it per frame. Per-curator presentation, so
// local.
[
    QGVAR(markers), "CHECKBOX",
    [LSTRING(Markers), LSTRING(Markers_Description)],
    _category,
    true,
    false // Local
] call CBA_fnc_addSetting;

// Read in both draw passes, once per pass rather than per record.
[
    QGVAR(drawLine), "CHECKBOX",
    [LSTRING(DrawLine), LSTRING(DrawLine_Description)],
    _category,
    true,
    false // Local
] call CBA_fnc_addSetting;

// Read once per frame by FUNC(draw3D). The 3D marker only; the map marker is
// already bounded by the visible map area.
[
    QGVAR(maxDistance), "SLIDER",
    [LSTRING(MaxDistance), LSTRING(MaxDistance_Description)],
    _category,
    [500, 10000, 2500, 0],
    false // Local
] call CBA_fnc_addSetting;
