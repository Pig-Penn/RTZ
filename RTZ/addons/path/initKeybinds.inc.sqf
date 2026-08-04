private _category = ELSTRING(main,DisplayName);

// One key both enters planning mode and executes what was drawn, which is the
// gesture Wargame trains its users into and the reason the mode feels quick:
// tap, trace, tap. Escape cancels without ordering anything (FUNC(handleInput)).
//
// The handler guards itself with CHECK_CURATOR_INPUT and returns false whenever
// it declines to act — Zeus closed, search box focused, nothing pathable
// selected — so the key passes through instead of being swallowed, matching
// rtz_orders and rtz_reverse.
//
// Tab is deliberately unbound by default rather than taken: 0x0F is the Zeus
// interface's own team-switch/next-unit key in several setups and ZEN binds
// around it, so a default here would silently shadow whatever the curator
// already uses. Wargame owns Tab because it owns the whole interface; RTZ is a
// guest in ZEN's.
[_category, QGVAR(togglePlanning), [LSTRING(TogglePlanning), LSTRING(TogglePlanning_Description)],
    {call FUNC(togglePlanning)}, {}, [0, [false, false, false]]] call CBA_fnc_addKeybind; // Default: Unbound
