private _category = [ELSTRING(main,DisplayName), LSTRING(DisplayName)];

// Both are global: a maneuver's clock and its length are evaluated where the
// vehicle is local, not on the ordering curator's client, so every machine has
// to agree on them or the same order behaves differently per owner.

[
    QGVAR(timeout), "SLIDER",
    [LSTRING(Timeout), LSTRING(Timeout_Description)],
    _category,
    [5, 60, 10, 0],
    true // Global
] call CBA_fnc_addSetting;

// At the fixed REVERSE_SPEED the timeout is usually the binding limit, not this
// — the cap is here to stop one keystroke dragging a column across the map when
// a curator raises the timeout, not to be hit on an ordinary reposition.
[
    QGVAR(maxDistance), "SLIDER",
    [LSTRING(MaxDistance), LSTRING(MaxDistance_Description)],
    _category,
    [10, 500, 50, 0],
    true // Global
] call CBA_fnc_addSetting;
