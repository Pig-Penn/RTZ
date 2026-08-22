private _category = [ELSTRING(main,DisplayName), LSTRING(DisplayName)];

// GLOBAL, not client-local. The two halves of this component run on DIFFERENT
// machines — the aim session on the curator's client, FUNC(executeStrike) wherever
// the aircraft is local. If the two disagreed, a curator whose client has the
// feature on could send QGVAR(execute) to a machine that never expected to receive
// it. rtz_path carries this exact hazard for its commit event and resolves it the
// same way.
//
// Default OFF. This is a new, opt-in system that takes an aircraft off its AI and
// flies it on rails; no mission should acquire that merely by upgrading the mod.
[
    QGVAR(enabled), "CHECKBOX",
    [LSTRING(Enabled), LSTRING(Enabled_Description)],
    _category,
    false,
    true // Global
] call CBA_fnc_addSetting;
