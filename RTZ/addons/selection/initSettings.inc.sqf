// ── Unit head tags (rtz_fnc_unitTags) — per-client display customization ────
// All client-local (isGlobal 0): each curator styles their own overlay. The
// master switch takes effect at mission start (postInit gate); flipping it
// mid-mission still shows/hides tags via the CBA_SettingChanged sync.

private _catTags     = [ELSTRING(main,DisplayName), LSTRING(CategoryDogTags)];
private _catVehTags  = [ELSTRING(main,DisplayName), LSTRING(CategoryVehicleTags)];
private _catOverlays = [ELSTRING(main,DisplayName), LSTRING(CategoryOverlays)];

[
    QGVAR(enableUnitTags),
    "CHECKBOX",
    [LSTRING(EnableUnitTags), LSTRING(EnableUnitTags_Description)],
    _catTags,
    true,
    0
] call CBA_fnc_addSetting;

{
    _x params ["_name", "_title", "_tooltip", "_default"];
    [
        _name, "CHECKBOX", [_title, _tooltip],
        _catTags,
        _default, 0
    ] call CBA_fnc_addSetting;
} forEach [
    [QGVAR(tagShowRole),        LSTRING(TagShowRole),        LSTRING(TagShowRole_Description),        false],
    [QGVAR(tagShowHealth),      LSTRING(TagShowHealth),      LSTRING(TagShowHealth_Description),       true],
    [QGVAR(tagShowMorale),      LSTRING(TagShowMorale),      LSTRING(TagShowMorale_Description),       false],
    [QGVAR(tagShowSuppression), LSTRING(TagShowSuppression), LSTRING(TagShowSuppression_Description),  false],
    [QGVAR(tagShowAmmo),        LSTRING(TagShowAmmo),        LSTRING(TagShowAmmo_Description),         false],
    [QGVAR(tagShowStatus),      LSTRING(TagShowStatus),      LSTRING(TagShowStatus_Description),       true],
    [QGVAR(tagShowTactic),      LSTRING(TagShowTactic),      LSTRING(TagShowTactic_Description),       true],
    [QGVAR(tagShowCommand),     LSTRING(TagShowCommand),     LSTRING(TagShowCommand_Description),      false],
    [QGVAR(tagShowFlagIcon),    LSTRING(TagShowFlagIcon),    LSTRING(TagShowFlagIcon_Description),     false],
    [QGVAR(tagShowThreatIcon),  LSTRING(TagShowThreatIcon),  LSTRING(TagShowThreatIcon_Description),   false]
];

[
    QGVAR(tagSize),
    "SLIDER",
    [LSTRING(TagSize), LSTRING(TagSize_Description)],
    _catTags,
    [0.02, 0.05, 0.03, 3],
    0
] call CBA_fnc_addSetting;

[
    QGVAR(tagHeight),
    "SLIDER",
    [LSTRING(TagHeight), LSTRING(TagHeight_Description)],
    _catTags,
    [0, 2, 0.5, 2],
    0
] call CBA_fnc_addSetting;

[
    QGVAR(tagMaxDistance),
    "SLIDER",
    [LSTRING(TagMaxDistance), LSTRING(TagMaxDistance_Description)],
    _catTags,
    [100, 1000, 200, 0],
    0
] call CBA_fnc_addSetting;

// ── Vehicle tags (rtz_fnc_vehicleTags) — per-client display customization ───
// All client-local (isGlobal 0), mirroring the Dog Tags block above. The
// master switch takes effect at mission start (postInit gate); flipping it
// mid-mission still shows/hides tags via the CBA_SettingChanged sync.

[
    QGVAR(enableVehicleTags),
    "CHECKBOX",
    [LSTRING(EnableVehicleTags), LSTRING(EnableVehicleTags_Description)],
    _catVehTags,
    true,
    0
] call CBA_fnc_addSetting;

{
    _x params ["_name", "_title", "_tooltip", "_default"];
    [
        _name, "CHECKBOX", [_title, _tooltip],
        _catVehTags,
        _default, 0
    ] call CBA_fnc_addSetting;
} forEach [
    [QGVAR(vtagShowName),      LSTRING(VtagShowName),      LSTRING(VtagShowName_Description),      false],
    [QGVAR(vtagShowSpeed),     LSTRING(VtagShowSpeed),     LSTRING(VtagShowSpeed_Description),      true],
    [QGVAR(vtagShowCrew),      LSTRING(VtagShowCrew),      LSTRING(VtagShowCrew_Description),       true],
    [QGVAR(vtagShowFuel),      LSTRING(VtagShowFuel),      LSTRING(VtagShowFuel_Description),      false],
    [QGVAR(vtagShowHull),      LSTRING(VtagShowHull),      LSTRING(VtagShowHull_Description),       true],
    [QGVAR(vtagShowFlyHeight), LSTRING(VtagShowFlyHeight), LSTRING(VtagShowFlyHeight_Description),  true],
    [QGVAR(vtagShowAmmo),      LSTRING(VtagShowAmmo),      LSTRING(VtagShowAmmo_Description),      false],
    [QGVAR(vtagShowCommander), LSTRING(VtagShowCommander), LSTRING(VtagShowCommander_Description), false],
    [QGVAR(vtagShowStatus),    LSTRING(VtagShowStatus),    LSTRING(VtagShowStatus_Description),     true],
    [QGVAR(vtagShowTactic),    LSTRING(VtagShowTactic),    LSTRING(VtagShowTactic_Description),     true]
];

[
    QGVAR(vtagSize),
    "SLIDER",
    [LSTRING(VtagSize), LSTRING(VtagSize_Description)],
    _catVehTags,
    [0.02, 0.05, 0.03, 3],
    0
] call CBA_fnc_addSetting;

[
    QGVAR(vtagHeight),
    "SLIDER",
    [LSTRING(VtagHeight), LSTRING(VtagHeight_Description)],
    _catVehTags,
    [0, 6, 2.5, 2],
    0
] call CBA_fnc_addSetting;

[
    QGVAR(vtagMaxDistance),
    "SLIDER",
    [LSTRING(VtagMaxDistance), LSTRING(VtagMaxDistance_Description)],
    _catVehTags,
    [100, 1000, 200, 0],
    0
] call CBA_fnc_addSetting;

[
    QGVAR(enableSelectionInfo),
    "CHECKBOX",
    [LSTRING(EnableSelectionInfo), LSTRING(EnableSelectionInfo_Description)],
    _catOverlays,
    true,
    0
] call CBA_fnc_addSetting;

[
    QGVAR(enableVehicleOverlay),
    "CHECKBOX",
    [LSTRING(EnableVehicleOverlay), LSTRING(EnableVehicleOverlay_Description)],
    _catOverlays,
    false,
    0
] call CBA_fnc_addSetting;
