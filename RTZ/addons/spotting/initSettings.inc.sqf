private _category = [ELSTRING(main,DisplayName), LSTRING(DisplayName)];

[
    QGVAR(enableSpottingSystem), "CHECKBOX",
    [LSTRING(EnableSpotting), LSTRING(EnableSpotting_Description)],
    _category,
    true,
    true // Global
] call CBA_fnc_addSetting;

[
    QGVAR(chevronNames), "CHECKBOX",
    [LSTRING(ChevronNames), LSTRING(ChevronNames_Description)],
    _category,
    false,
    false // Local
] call CBA_fnc_addSetting;

// GLOBAL, not local. The work this switches off is the SERVER's — the wedge lookup
// FUNC(spotCheck) rebuilds every pass, and one targeted event per shooter per watching
// curator — so a per-client preference would hide the flash while paying for all of it.
[
    QGVAR(enableFireBlink), "CHECKBOX",
    [LSTRING(EnableFireBlink), LSTRING(EnableFireBlink_Description)],
    _category,
    true,
    true // Global
] call CBA_fnc_addSetting;

[
    QGVAR(enableRemoteControlIndicator), "CHECKBOX",
    [LSTRING(EnableRC), LSTRING(EnableRC_Description)],
    _category,
    true,
    true // Global
] call CBA_fnc_addSetting;

[
    QGVAR(spotCheckInterval), "SLIDER",
    [LSTRING(CheckInterval), LSTRING(CheckInterval_Description)],
    _category,
    [1, 10, 3, 0],
    true // Global
] call CBA_fnc_addSetting;

// The FALLBACK cadence, not the detection mechanism: takeover and release are picked up
// from the controller's own client within a tick (see FUNC(remoteControlIndicator)), and
// this scan only has to catch what no event reported — a controller disconnecting
// mid-takeover, chiefly. It was a 1-10 s slider back when it WAS the detection, which
// meant walking allUnits with a getVariable each, every few seconds, for the whole
// mission, to answer "nobody". Lower it only if an indicator is ever seen to stick.
[
    QGVAR(rcCheckInterval), "SLIDER",
    [LSTRING(RCCheckInterval), LSTRING(RCCheckInterval_Description)],
    _category,
    [5, 120, 30, 0],
    true // Global
] call CBA_fnc_addSetting;
