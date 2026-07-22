private _category = ELSTRING(main,DisplayName);

// Point-free deletion of the current selection. Shift is deliberate: plain
// Delete stays with Zeus's own (refunding) delete action, so both remain
// available. The handler checks its own preconditions and reads the setting at
// press time (see fnc_deleteSelected).
[_category, QGVAR(deleteSelected), [LSTRING(DeleteSelected), LSTRING(DeleteSelected_Description)],
    {call FUNC(deleteSelected)}, {}, [0xD3, [true, false, false]]] call CBA_fnc_addKeybind; // Default: Shift + Delete
