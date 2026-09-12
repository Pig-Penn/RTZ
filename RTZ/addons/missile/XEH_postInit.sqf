#include "script_component.hpp"

// Detection is a class event handler on AllVehicles — men, land, air and ships all
// inherit from it, and IncomingMissile can fire on any of them. Registered on every
// machine.
//
// Units ALREADY on the map are covered, but by CBA_fnc_addClassEventHandler's own
// unconditional sweep over `entities`, NOT by its _applyInitRetroactively flag, which
// both of these calls used to pass true for. That flag is forced back to false for
// every event that is not "init"/"initPost", so on "IncomingMissile" and "FiredMan"
// it was a no-op crediting the wrong mechanism.
//
// A class event handler CANNOT be removed once added, which is why GVAR(enabled) is
// a gate inside FUNC(detectIncoming) rather than a conditional registration here —
// the same reasoning as rtz_spotting's FiredMan handler.
["AllVehicles", "IncomingMissile", LINKFUNC(detectIncoming), true, []] call CBA_fnc_addClassEventHandler;

// The grenade half. CAManBase rather than AllVehicles — only a man throws — and
// FiredMan rather than Fired, which is the man-specific form. Registered on every
// machine and narrowed by `local _unit` inside, because ZEN's throw runs wherever
// the UNIT is local and RTZ units are local to the curator that spawned them, not
// to the server.
//
// This is the mod's SECOND un-removable CAManBase FiredMan class event handler,
// alongside rtz_spotting's fire-blink. Every infantry shot in the mission now pays
// two handler entries rather than one; each is an array index and a string compare
// before anything else happens, which is why FUNC(detectGrenade) tests the weapon
// ahead of its own params call.
["CAManBase", "FiredMan", LINKFUNC(detectGrenade), true, []] call CBA_fnc_addClassEventHandler;

// Only the server can resolve which curators own an object: curator modules are
// server-local (see EFUNC(common,curatorsOf)).
if (isServer) then {
    [QGVAR(incoming), LINKFUNC(reportIncoming)] call CBA_fnc_addEventHandler;
    [QGVAR(grenade), LINKFUNC(reportGrenade)] call CBA_fnc_addEventHandler;
};

if (!hasInterface) exitWith {};

// Registered unconditionally, NOT behind CBA_settingsInitialized: a receiver that
// does not exist when the first event arrives simply loses it.
//
// ONE receiver for both kinds — the payload carries REC_KIND and FUNC(receiveTrack)
// builds the record from it.
[QGVAR(track), LINKFUNC(receiveTrack)] call CBA_fnc_addEventHandler;

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
