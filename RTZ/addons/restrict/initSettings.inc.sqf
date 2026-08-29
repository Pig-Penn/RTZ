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

// Hides LAMBS' nine scripted waypoint types from ZEN's waypoint Type toolbox;
// ZEN_CfgWaypointTypes.hpp carries the reasoning and the config side.
//
// Defaults ON, unlike its two siblings. Those take away something a curator can
// otherwise do, so they wait to be asked for. This one takes away a strictly
// worse way of doing something that remains available, in fuller form, as a
// LAMBS module — so the decluttered list is the honest default.
//
// Global rather than client-side even though the condition is evaluated on the
// curator's own machine: which orders exist is a property of the mission, not a
// per-curator display preference like EGVAR(common,enableCleanContextMenu).
[
    QGVAR(lambsWaypoints), "CHECKBOX",
    [LSTRING(LambsWaypoints), LSTRING(LambsWaypoints_Description)],
    _category,
    true,
    true // Global
] call CBA_fnc_addSetting;
