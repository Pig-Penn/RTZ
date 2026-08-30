private _category = ELSTRING(main,DisplayName);

// Keyboard twin of the RTZ_Control > Reset context action. The handler guards
// itself with CHECK_CURATOR_INPUT and returns false whenever it declines to act
// — Zeus closed, search box focused, nothing resettable selected — so the bind
// is registered unconditionally and the key passes through rather than being
// swallowed (see fnc_resetSelected). The action itself has no setting to read:
// it is always on, like the context entry it mirrors.
//
// Shift + grave. 0x29 is a POSITIONAL scan code — the key left of 1 — so it
// lands in the same place whatever the curator's keyboard layout prints on it.
// Shift is what keeps it clear of the radio mods: ACRE and TFAR commonly sit on
// plain grave for push-to-talk, and a swallowed PTT inside the Zeus interface
// would be an unpleasant surprise mid-operation.
[_category, QGVAR(resetSelected), [LSTRING(ResetSelected), LSTRING(ResetSelected_Description)],
    {call FUNC(resetSelected)}, {}, [0x29, [true, false, false]]] call CBA_fnc_addKeybind; // Default: Shift + `
