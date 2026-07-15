// ── Unit head tags (rtz_fnc_unitTags) — per-client display customization ────
// All client-local (isGlobal 0): each curator styles their own overlay. The
// master switch takes effect at mission start (postInit gate); flipping it
// mid-mission still shows/hides tags via the CBA_SettingChanged sync.

[
    QGVAR(enableUnitTags),
    "CHECKBOX",
    ["Dog Tags", "Show a small floating status tag above each selected infantry unit in Zeus. Requires Selection Info enabled. Toggle in-mission via keybind or the RTZ context menu."],
    ["Real-Time Zeus", "Dog Tags"],
    true,
    0
] call CBA_fnc_addSetting;

{
    _x params ["_name", "_title", "_tooltip", "_default"];
    [
        _name, "CHECKBOX", [_title, _tooltip],
        ["Real-Time Zeus", "Dog Tags"],
        _default, 0
    ] call CBA_fnc_addSetting;
} forEach [
    [QGVAR(tagShowRole),        "Show Role",        "Include the unit's role (class display name).", true],
    [QGVAR(tagShowName),        "Show Name",        "Include the unit's name.", false],
    [QGVAR(tagShowHealth),      "Show Health",      "Include HP percentage (only shown when below 100).", true],
    [QGVAR(tagShowMorale),      "Show Morale",      "Include morale percentage.", false],
    [QGVAR(tagShowSuppression), "Show Suppression", "Include suppression percentage while the unit is suppressed.", true],
    [QGVAR(tagShowAmmo),        "Show Ammo",        "Include rounds left in the current primary-weapon magazine.", false],
    [QGVAR(tagShowStatus),      "Show Status",      "Include the current LAMBS task. DOWN / FLEEING always shows regardless.", true],
    [QGVAR(tagShowTactic),      "Show Tactic",      "Include the group's current LAMBS tactic (leader's tag only).", false],
    [QGVAR(tagShowIntel),       "Show Leader Intel","Include known-enemy and group-memory counts (leader's tag only).", false],
    [QGVAR(tagShowFlagIcon),    "Show Flag Icon",   "Show a flag icon at the right end of the tag when the unit carries status flags (WOUNDED, HIDDEN, BUSY, PATH OFF, ...). Hover the Zeus cursor over it to list them.", true],
    [QGVAR(tagShowStateIcon),   "Show AI State Icon","Show a small icon left of the tag for the unit's behaviour/combat mode (mirrors the selection dialog's icon). Hover to see behaviour, state, and current command.", true],
    [QGVAR(tagShowThreatIcon),  "Show Threat Icon", "Show a danger or target-lock icon right of the tag (danger cause wins over a target lock). Hover for the full detail.", true],
    [QGVAR(tagSideColors),      "Side Colors",      "Tint calm units' tags with their side colour instead of white. Urgency colours (amber/red) always win.", false]
];

[
    QGVAR(tagSize),
    "SLIDER",
    ["Tag Size", "Text size of the unit tags."],
    ["Real-Time Zeus", "Dog Tags"],
    [0.02, 0.05, 0.03, 3],
    0
] call CBA_fnc_addSetting;

[
    QGVAR(tagHeight),
    "SLIDER",
    ["Tag Height", "Metres above the unit's head."],
    ["Real-Time Zeus", "Dog Tags"],
    [0, 2, 0.5, 2],
    0
] call CBA_fnc_addSetting;

[
    QGVAR(tagMaxDistance),
    "SLIDER",
    ["Tag Draw Distance", "Camera distance (metres) beyond which tags fade out."],
    ["Real-Time Zeus", "Dog Tags"],
    [200, 5000, 1500, 0],
    0
] call CBA_fnc_addSetting;

// ── Vehicle tags (rtz_fnc_vehicleTags) — per-client display customization ───
// All client-local (isGlobal 0), mirroring the Dog Tags block above. The
// master switch takes effect at mission start (postInit gate); flipping it
// mid-mission still shows/hides tags via the CBA_SettingChanged sync.

[
    QGVAR(enableVehicleTags),
    "CHECKBOX",
    ["Vehicle Tags", "Show a small floating status tag above each selected vehicle in Zeus. Requires Selection Info enabled. Toggle in-mission via the RTZ context menu."],
    ["Real-Time Zeus", "Vehicle Tags"],
    true,
    0
] call CBA_fnc_addSetting;

{
    _x params ["_name", "_title", "_tooltip", "_default"];
    [
        _name, "CHECKBOX", [_title, _tooltip],
        ["Real-Time Zeus", "Vehicle Tags"],
        _default, 0
    ] call CBA_fnc_addSetting;
} forEach [
    [QGVAR(vtagShowName),      "Show Name",       "Include the vehicle's name (class display name).", true],
    [QGVAR(vtagShowSpeed),     "Show Speed",      "Include the current speed (only shown while moving).", true],
    [QGVAR(vtagShowCrew),      "Show Crew",       "Include aboard/total seat counts.", true],
    [QGVAR(vtagShowFuel),      "Show Fuel",       "Include fuel percentage (only shown when below 100).", true],
    [QGVAR(vtagShowHull),      "Show Hull",       "Include hull integrity percentage (only shown when below 100).", true],
    [QGVAR(vtagShowFlyHeight), "Show Fly Height", "Include a helicopter's commanded AI fly-in height (set with the fly-height keybinds). Only shown once ordered.", true],
    [QGVAR(vtagShowAmmo),      "Show Ammo",       "Include rounds left in the crew's currently selected weapon.", false],
    [QGVAR(vtagShowCommander), "Show Commander",  "Include the effective commander's name.", false],
    [QGVAR(vtagShowStatus),    "Show Status",     "Include the crew's current LAMBS task. LOW FUEL / DAMAGED warnings always show regardless.", true],
    [QGVAR(vtagShowTactic),    "Show Tactic",     "Include the crew group's current LAMBS tactic.", false],
    [QGVAR(vtagSideColors),    "Side Colors",     "Tint tags with the vehicle's side colour instead of white. Warning colours (amber/red) always win.", false]
];

[
    QGVAR(vtagSize),
    "SLIDER",
    ["Tag Size", "Text size of the vehicle tags."],
    ["Real-Time Zeus", "Vehicle Tags"],
    [0.02, 0.05, 0.03, 3],
    0
] call CBA_fnc_addSetting;

[
    QGVAR(vtagHeight),
    "SLIDER",
    ["Tag Height", "Metres above the vehicle."],
    ["Real-Time Zeus", "Vehicle Tags"],
    [0, 6, 2.5, 2],
    0
] call CBA_fnc_addSetting;

[
    QGVAR(vtagMaxDistance),
    "SLIDER",
    ["Tag Draw Distance", "Camera distance (metres) beyond which vehicle tags fade out."],
    ["Real-Time Zeus", "Vehicle Tags"],
    [200, 5000, 1500, 0],
    0
] call CBA_fnc_addSetting;

[
    QGVAR(enableSelectionInfo),
    "CHECKBOX",
    ["Selection Info", "Show unit state panel (behaviour, morale, suppression, LAMBS task) when infantry is selected in Zeus."],
    ["Real-Time Zeus", "Overlays"],
    true,
    0
] call CBA_fnc_addSetting;

[
    QGVAR(enableVehicleOverlay),
    "CHECKBOX",
    ["Vehicle Overlay", "Show stat cards (speed, fuel, ammo, crew, LAMBS task) for selected vehicles in Zeus. Requires Selection Info enabled."],
    ["Real-Time Zeus", "Overlays"],
    false,
    0
] call CBA_fnc_addSetting;
