// ── Unit head tags (FUNC(drawUnitTags)) — per-client display customization ─
// All client-local (isGlobal 0): each curator styles their own overlay. The
// master switch takes effect at mission start (postInit gate); flipping it
// mid-mission still shows/hides tags via the CBA_SettingChanged sync.

// The tag blocks do NOT sit under the mod's own "Real-Time Zeus" entry. Between
// them they are ~30 of the mod's ~100 settings — a third of one page — so they
// get their own top-level entry in the CBA category dropdown, "Real-Time Zeus -
// Dog Tags" (prefixed so it sorts beside the main page rather than off among
// the other mods), split into an infantry and a vehicle subcategory inside it.
// Everything else in this file (the Overlays block) stays on the main RTZ page.
private _catTags     = [LSTRING(CategoryDogTags), LSTRING(CategoryUnitTags)];
private _catVehTags  = [LSTRING(CategoryDogTags), LSTRING(CategoryVehicleTags)];
// rtz_core's key, NOT a local copy. CBA groups settings by the LOCALIZED STRING,
// so this component's overlay switches and the engine's cadence knob shared a
// category only because two separate stringtable entries happened to hold
// byte-identical English. The first translation of either would have silently
// split them into two categories. rtz_core is already a hard dependency.
private _catOverlays = [ELSTRING(main,DisplayName), ELSTRING(core,CategoryOverlays)];

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
    [QGVAR(tagShowAmmoBar),     LSTRING(TagShowAmmoBar),     LSTRING(TagShowAmmoBar_Description),      false],
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
    // Fraction of SCREEN HEIGHT, not metres — FUNC(drawUnitTags) lifts the tag by
    // a measured UI offset so the gap holds at any distance, pitch and zoom. The
    // default reproduces what the old 0.5 m setting drew at the reference FOV.
    [0, 0.15, 0.02, 3],
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

// ── Vehicle tags (FUNC(drawVehicleTags)) — per-client display customization
// All client-local (isGlobal 0), mirroring the Unit Tags block above — and its
// sibling subcategory under the same "Real-Time Zeus - Dog Tags" entry. The
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
    [QGVAR(vtagShowAmmoBar),   LSTRING(VtagShowAmmoBar),   LSTRING(VtagShowAmmoBar_Description),   false],
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
    // Fraction of SCREEN HEIGHT, not metres — see QGVAR(tagHeight) above. The
    // default reproduces what the old 2.5 m setting drew at the reference FOV.
    [0, 0.25, 0.10, 3],
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

// Server-global (unlike the per-client display settings above): the cadence of
// the selection feeds (infantry + vehicle packets) in the shared stream engine.
// Read live each tick, so it can be retuned mid-mission.
[
    QGVAR(gatherInterval),
    "SLIDER",
    [LSTRING(GatherInterval), LSTRING(GatherInterval_Description)],
    _catOverlays,
    [0.25, 5, 0.3, 2],
    true // Global
] call CBA_fnc_addSetting;

// ── AI-state overlays (destination / target streams) ────────────────────────
// Neither master switch needs a mission restart. The stream machinery is
// registered unconditionally on every machine (see XEH_postInit) and is idle
// while nothing is subscribed, so these only gate the context ACTION — read live
// by its condition — and EFUNC(core,streamClient) watches CBA_SettingChanged to shut a
// running overlay down if its switch goes off mid-mission.

[
    QGVAR(enableDestinationDisplay), "CHECKBOX",
    [LSTRING(DrawDestinations), LSTRING(DrawDestinations_Description)],
    _catOverlays,
    true,
    true // Global
] call CBA_fnc_addSetting;

[
    QGVAR(enableTargetDisplay), "CHECKBOX",
    [LSTRING(DrawTargets), LSTRING(DrawTargets_Description)],
    _catOverlays,
    true,
    true // Global
] call CBA_fnc_addSetting;

[
    QGVAR(destGrowWithSpeed), "CHECKBOX",
    [LSTRING(DestinationIconScaling), LSTRING(DestinationIconScaling_Description)],
    _catOverlays,
    false,
    0 // Client
] call CBA_fnc_addSetting;

// NOTE: the cadence of the AI-state overlay streams is NOT declared here. It is
// EGVAR(core,pollInterval), registered by the engine that runs them, because
// rtz_supply's supply-lines overlay rides the same knob and should not have to
// name a setting owned by a display component. It is declared with the same
// category text as these switches, so it still appears alongside them.
