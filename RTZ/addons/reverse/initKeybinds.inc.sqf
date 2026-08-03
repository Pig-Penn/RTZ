private _category = ELSTRING(main,DisplayName);

// Reverse the selected AI-driven land vehicles towards the cursor. Shift + R
// deliberately mirrors rtz_common's Shift + T reposition: the same "move the
// selection to where I am pointing" gesture, driven rather than teleported.
//
// The handler guards itself with CHECK_CURATOR_INPUT and reads its settings at
// press time, so the bind is registered unconditionally and returns false to
// pass the key through whenever it declines to act (see fnc_orderReverse) —
// including when nothing reversible is selected, which the old handler used to
// swallow.
[_category, QGVAR(reverseToCursor), [LSTRING(ReverseToCursor), LSTRING(ReverseToCursor_Description)],
    {call FUNC(orderReverse)}, {}, [0x13, [true, false, false]]] call CBA_fnc_addKeybind; // Default: Shift + R
