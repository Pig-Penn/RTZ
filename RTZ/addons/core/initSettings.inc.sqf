// Same displayed text as rtz_hud's overlay category, so the engine's cadence knob
// and the display switches it paces land together in one CBA category.
private _catOverlays = [ELSTRING(main,DisplayName), LSTRING(CategoryOverlays)];

// Cadence shared by every AI-state overlay stream, in this component or any
// other (rtz_hud's destination and target feeds, rtz_supply's supply lines).
// Lives HERE rather than with any one of them: it is the engine's knob, and while
// it sat in rtz_hud, rtz_supply had to name a setting belonging to a display addon
// it otherwise has no business depending on.
//
// Deliberately separate from rtz_hud's own gatherInterval, which paces the
// selection feeds: these overlays read much heavier engine state
// (expectedDestination / targetKnowledge) and are useful an order of magnitude
// slower. The stream engine runs each feed at its own rate off one loop.
//
// Server-global, and read live each tick, so it can be retuned mid-mission.
[
    QGVAR(pollInterval), "SLIDER",
    [LSTRING(PollInterval), LSTRING(PollInterval_Description)],
    _catOverlays,
    [0.5, 10, 2, 1],
    true // Global
] call CBA_fnc_addSetting;
