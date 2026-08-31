#include "script_component.hpp"

// Detection is a class event handler on AllVehicles — men, land, air and ships all
// inherit from it, and IncomingMissile can fire on any of them. Registered on every
// machine and applied retroactively so units already on the map are covered too.
//
// A class event handler CANNOT be removed once added, which is why GVAR(enabled) is
// a gate inside FUNC(detectIncoming) rather than a conditional registration here —
// the same reasoning as rtz_spotting's FiredMan handler.
["AllVehicles", "IncomingMissile", LINKFUNC(detectIncoming), true, [], true] call CBA_fnc_addClassEventHandler;

// Only the server can resolve which curators own an object: curator modules are
// server-local (see EFUNC(common,curatorsOf)).
if (isServer) then {
    [QGVAR(incoming), LINKFUNC(reportIncoming)] call CBA_fnc_addEventHandler;
};

if (!hasInterface) exitWith {};

// Registered unconditionally, NOT behind CBA_settingsInitialized: a receiver that
// does not exist when the first event arrives simply loses it.
[QGVAR(track), LINKFUNC(receiveIncoming)] call CBA_fnc_addEventHandler;

// Only draw while the Zeus display is open — this is a curator-only overlay
["zen_curatorDisplayLoaded", { _this call FUNC(start) }] call CBA_fnc_addEventHandler;
["zen_curatorDisplayUnloaded", { call FUNC(stop) }] call CBA_fnc_addEventHandler;

// FUNC(start) registers the handlers when the setting is on and tears them down
// when it goes off, so re-running it IS the toggle. Applying it live means a
// curator flipping the markers off stops paying for them immediately rather than
// at the next mission — and it is the reason neither draw function has to re-test
// its setting every frame.
["CBA_SettingChanged", {
    params ["_name"];

    // Lowercased on both sides: CBA_SettingChanged is not guaranteed to report the
    // name in the case it was registered with.
    if ((toLower _name) isNotEqualTo (toLower QGVAR(markers))) exitWith {};

    // Nothing to start unless Zeus is actually open — FUNC(start) is otherwise only
    // ever reached through zen_curatorDisplayLoaded
    if (isNull (findDisplay IDD_RSCDISPLAYCURATOR)) exitWith {};

    [] call FUNC(start);
}] call CBA_fnc_addEventHandler;
