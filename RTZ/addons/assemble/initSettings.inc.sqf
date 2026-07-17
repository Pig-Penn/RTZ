private _category = [ELSTRING(main,DisplayName), LSTRING(DisplayName)];

// Master switch — hides the Assemble and Disassemble context menu actions entirely.
// Client-side: it is read by FUNC(canAssemble) / FUNC(canDisassemble) on the
// curator's own machine and only gates what he can order. The server-side errand
// receivers register unconditionally (see XEH_postInit), so a curator flipping this
// locally can never end up with an action whose server half was never registered
[
    QGVAR(enabled), "CHECKBOX",
    [LSTRING(Enabled), LSTRING(Enabled_Description)],
    _category,
    true,
    false
] call CBA_fnc_addSetting;

// Global (server-synced): read on the machine that runs the errand (the server for
// Zeus AI), not on the curator's client
[
    QGVAR(instant), "CHECKBOX",
    [LSTRING(Instant), LSTRING(Instant_Description)],
    _category,
    false,
    true
] call CBA_fnc_addSetting;
