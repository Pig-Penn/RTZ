private _category = [ELSTRING(main,DisplayName), LSTRING(DisplayName)];

// Global. Both of the gates below are read on the curator's client at commit
// time, but they are a mission rule rather than a personal preference: two
// curators disagreeing about how far a unit may be repositioned, or how long
// they must wait between repositions, is exactly the asymmetry the gates exist
// to prevent. Carried over unchanged from rtz_orders' teleport settings, which
// this mode replaces — same ranges, same defaults, same scope.
//
// NEVER 0: FUNC(commitPlacement) divides the travelled distance by this to scale
// the cooldown. The slider floor of 10 is what guarantees it.
[
    QGVAR(maxDistance), "SLIDER",
    [LSTRING(MaxDistance), LSTRING(MaxDistance_Description)],
    _category,
    [10, 500, 150, 0],
    true // Global
] call CBA_fnc_addSetting;

[
    QGVAR(cooldown), "SLIDER",
    [LSTRING(Cooldown), LSTRING(Cooldown_Description)],
    _category,
    [0, 60, 10, 0],
    true // Global
] call CBA_fnc_addSetting;

// Client-side: this decides how many local ghost MODELS this curator's own
// machine spawns for its own session and is invisible to everyone else, so two
// curators on different hardware can reasonably disagree. Above the cap the
// session still runs in full — every ghost keeps its helper, its icon and its
// drag — it just stops spawning models, which is the only part whose cost grows
// with the selection.
[
    QGVAR(ghostModelMax), "SLIDER",
    [LSTRING(GhostModelMax), LSTRING(GhostModelMax_Description)],
    _category,
    [0, 60, 30, 0],
    false // Client
] call CBA_fnc_addSetting;
