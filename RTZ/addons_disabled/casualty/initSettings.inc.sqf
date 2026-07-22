private _category = [ELSTRING(main,DisplayName), LSTRING(DisplayName)];

// Master switch. OFF by default: this system alters core death behaviour, so it is
// strictly opt-in. While off nothing is registered (see XEH_postInit) — no HandleDamage
// event handlers are attached to any unit, so the cost is exactly zero.
[
    QGVAR(enable), "CHECKBOX",
    [LSTRING(Enable), LSTRING(Enable_Description)],
    _category,
    false,
    true
] call CBA_fnc_addSetting;

// Probability a would-be-fatal infantry hit becomes a casualty instead of a kill.
// Deliberately small — this is a rare "second chance", not a revive-everyone system.
[
    QGVAR(chance), "SLIDER",
    [LSTRING(SurvivalChance), LSTRING(SurvivalChance_Description)],
    _category,
    [0, 0.5, 0.05, 2],
    true
] call CBA_fnc_addSetting;

// Seconds a downed (not-yet-loaded) casualty survives before bleeding out. Loading
// into a medical vehicle pauses this clock; delivery to a safe zone clears it.
[
    QGVAR(bleedoutTime), "SLIDER",
    [LSTRING(BleedoutTime), LSTRING(BleedoutTime_Description)],
    _category,
    [30, 1200, 300, 0],
    true
] call CBA_fnc_addSetting;

// How close a friendly, crewed medical vehicle must be for the "Load into Medical
// Vehicle" context action to succeed.
[
    QGVAR(loadRadius), "SLIDER",
    [LSTRING(LoadingRadius), LSTRING(LoadingRadius_Description)],
    _category,
    [5, 50, 15, 0],
    true
] call CBA_fnc_addSetting;

// How close the medical vehicle must get to a friendly HQ / safe-zone marker to
// complete the evacuation (and save the casualty). See FUNC(findSafeZone).
[
    QGVAR(deliverRadius), "SLIDER",
    [LSTRING(DeliveryRadius), LSTRING(DeliveryRadius_Description)],
    _category,
    [10, 200, 40, 0],
    true
] call CBA_fnc_addSetting;

// Radius (m) of a "Medical Zone" module dropped by a curator. This becomes the
// safe-zone marker's size; a casualty delivered inside it completes evacuation.
[
    QGVAR(zoneRadius), "SLIDER",
    [LSTRING(MedicalZoneRadius), LSTRING(MedicalZoneRadius_Description)],
    _category,
    [10, 200, 50, 0],
    true
] call CBA_fnc_addSetting;
