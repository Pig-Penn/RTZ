private _category = ELSTRING(main,DisplayName);

// One key both opens the placement session and commits it, which is the gesture
// that makes the mode quick to use — tap, arrange, tap — and the same one
// rtz_path is built around. Tapping twice with nothing dragged in between
// reproduces the one-shot teleport this mode replaces, so the fast path costs
// exactly one extra keystroke and no relearning.
//
// Enter also commits and Escape cancels, both from FUNC(handleInput) — Enter
// because that is what a curator reaches for to confirm a placement, and Escape
// because a mode that cannot be abandoned without consequence is one curators
// stop opening.
//
// Shift + T deliberately: it is the key the teleport-to-cursor order it replaces
// has always used, so existing muscle memory keeps working. Registered here
// rather than in rtz_orders because the session, not the order, is what the key
// now opens.
//
// The handler guards itself with CHECK_CURATOR_INPUT and returns false whenever
// it declines to act — Zeus closed, search box focused, nothing selected — so
// the key passes through instead of being swallowed, matching rtz_orders,
// rtz_path and rtz_slide.
[_category, QGVAR(togglePlacement), [LSTRING(TogglePlacement), LSTRING(TogglePlacement_Description)],
    {call FUNC(togglePlacement)}, {}, [0x14, [true, false, false]]] call CBA_fnc_addKeybind; // Default: Shift + T
