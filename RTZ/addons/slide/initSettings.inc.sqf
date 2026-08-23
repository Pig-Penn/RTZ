private _category = [ELSTRING(main,DisplayName), LSTRING(DisplayName)];

// Both are global: a maneuver's clock and its length are evaluated where the
// vehicle is local, not on the ordering curator's client, so every machine has
// to agree on them or the same order behaves differently per owner.

// A floor on how long a maneuver is given, not a ceiling: a slide too long for
// this window is granted the time its own distance needs (FUNC(slideTo)). Before
// that, a timeout shorter than the trip aborted the drive partway and left the
// vehicle short of the endpoint the curator had been drawn — the setting was
// silently deciding how far a slide could go, which is what maxDistance below is
// for. What it still does is bound a slide that is going nowhere.
[
    QGVAR(timeout), "SLIDER",
    [LSTRING(Timeout), LSTRING(Timeout_Description)],
    _category,
    [5, 60, 10, 0],
    true // Global
] call CBA_fnc_addSetting;

// This is now the only limit on how far one keystroke can drag a column, since
// the timeout above no longer cuts a drive short of its endpoint. Still not
// meant to be hit on an ordinary reposition — it is the backstop, not the rule.
[
    QGVAR(maxDistance), "SLIDER",
    [LSTRING(MaxDistance), LSTRING(MaxDistance_Description)],
    _category,
    [10, 100, 50, 0],
    true // Global
] call CBA_fnc_addSetting;
