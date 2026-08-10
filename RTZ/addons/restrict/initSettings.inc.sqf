private _category = [ELSTRING(main,DisplayName), LSTRING(DisplayName)];

[
    QGVAR(enabled), "CHECKBOX",
    [LSTRING(Enabled), LSTRING(Enabled_Description)],
    _category,
    true,
    true // Global
] call CBA_fnc_addSetting;

// Independent of the setting above, not nested under it: arsenal access and
// servicing access are separate permissions, and a mission may well want free
// servicing with locked loadouts or the reverse.
//
// Defaults off, unlike its sibling. The servicing restriction is what this
// component has always done; this one is new, so an existing mission keeps its
// current behaviour until someone asks for the change.
[
    QGVAR(arsenal), "CHECKBOX",
    [LSTRING(Arsenal), LSTRING(Arsenal_Description)],
    _category,
    false,
    true // Global
] call CBA_fnc_addSetting;
