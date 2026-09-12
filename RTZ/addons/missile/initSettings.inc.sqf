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

// The grenade half's own switch, kept separate from GVAR(enabled) so a mission can
// run one without the other — they answer different questions and cost different
// things. Global for the same reason: read wherever the THROWER is local (the gate
// in FUNC(detectGrenade)) and again on the server before the fan-out. Off, the
// whole half costs one array index and one string compare per infantry shot.
[
    QGVAR(grenadeEnabled), "CHECKBOX",
    [LSTRING(GrenadeEnabled), LSTRING(GrenadeEnabled_Description)],
    _category,
    true,
    true // Global
] call CBA_fnc_addSetting;

// Read on the server only, by FUNC(reportGrenade) when it decides who is close
// enough to warn. Nothing else reads it, so it is global rather than local —
// a per-curator value would be one every machine but the server ignores.
//
// The radius is measured from where the grenade is GOING — ZEN's aim point, which
// FUNC(detectGrenade) reads off the throw helper — not from the thrower, who can be
// up to 75 m away from it.
[
    QGVAR(grenadeRadius), "SLIDER",
    [LSTRING(GrenadeRadius), LSTRING(GrenadeRadius_Description)],
    _category,
    [10, 150, 40, 0],
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

// Read in both draw passes, once per pass rather than per record. Missiles only —
// a curator-ordered grenade is aimed at a position and has no target object to
// draw a line to.
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
