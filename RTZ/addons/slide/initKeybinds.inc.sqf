private _category = ELSTRING(main,DisplayName);

// Drive the selected AI-driven land vehicles straight to the cursor — forward or
// backward, chosen per vehicle by which side of it the cursor falls on. Shift + R
// deliberately mirrors rtz_common's Shift + T reposition: the same "move the
// selection to where I am pointing" gesture, driven rather than teleported.
//
// The handler guards itself with CHECK_CURATOR_INPUT and reads its settings at
// press time, so the bind is registered unconditionally and returns false to
// pass the key through whenever it declines to act (see fnc_orderSlide) —
// including when nothing drivable is selected, which the old handler used to
// swallow.
[_category, QGVAR(slideToCursor), [LSTRING(DriveToCursor), LSTRING(DriveToCursor_Description)],
    {call FUNC(orderSlide)}, {}, [0x13, [true, false, false]]] call CBA_fnc_addKeybind; // Default: Shift + R
