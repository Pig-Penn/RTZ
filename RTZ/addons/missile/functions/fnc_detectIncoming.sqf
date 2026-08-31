#include "script_component.hpp"
/*
 * Author: Maxim
 * IncomingMissile class event handler body. Reports a guided launch aimed at this
 * unit to the server, which decides which curators are entitled to see it.
 *
 * IncomingMissile fires on launch, not on lock — there is no lock-on event handler
 * in the engine. It is also wider than "guided missiles": for a player it only
 * fires once a guided weapon has locked, but for AI it fires for an unguided rocket
 * merely aimed at the target too. Only the guided half is wanted here — an AI
 * pointing a rocket pod at a truck is not the warning a curator asked for — so the
 * ammo is filtered below.
 *
 * The handler is installed on every machine (a class event handler cannot be
 * removed, so it has to be), and `local _target` picks exactly one reporter out of
 * them — which is why there is no de-duplication window on the server. RTZ's units
 * are typically local to the curator who spawned them rather than to the server,
 * so that reporter is usually a client.
 *
 * Arguments:
 * 0: Target <OBJECT>
 * 1: Ammo classname <STRING>
 * 2: Firing vehicle, or the unit itself for a soldier <OBJECT>
 * 3: Instigator <OBJECT>
 * 4: Projectile <OBJECT>
 *
 * Return Value:
 * None
 *
 * Example:
 * [_target, "M_Titan_AT", _launcher, _shooter, _missile] call rtz_missile_fnc_detectIncoming
 *
 * Public: No
 */

params ["_target", "_ammo", "_vehicle", "", "_missile"];

// Locality probe, deliberately in front of the gate below. IncomingMissile's
// locality is not documented anywhere reachable and community answers disagree
// between "every machine" and "where the target is local"; build with
// DEBUG_ENABLED_MISSILE and read the RPT to see which machines actually fire.
// If it turns out to fire ONLY where the firer is local, the gate below has to
// become `local _vehicle` instead.
TRACE_4("incoming",_target,local _target,local _vehicle,isServer);

if (!GVAR(enabled)) exitWith {};
if (!local _target) exitWith {};

// Guided only. "shotMissile" is the engine's own simulation type for a missile
// that steers itself at something — every ATGM and every lock-on AA/AT round —
// while an unguided rocket is "shotRocket" and a fired shell is "shotShell".
// Testing the simulation rather than a lock flag keeps modded ATGMs in: they all
// have to declare the simulation to be guided at all, whereas irLock/laserLock
// are set inconsistently across modsets.
//
// Memoized by ammo classname: this runs on every launch aimed at a unit local to
// this machine, and a rocket pod emptying would otherwise pay for a configFile
// read per rocket. The config answer for a class never changes within a session.
private _guided = GVAR(guidedAmmo) get _ammo;

if (isNil "_guided") then {
    // Flushed whole rather than evicted one at a time: the key space is the set of
    // ammo classes in the modset, so this is a safety net, not a working mechanism.
    if (count GVAR(guidedAmmo) > GUIDED_CACHE_MAX) then {
        GVAR(guidedAmmo) = createHashMap;
    };

    // Lowercased because config values are written by hand and mods are not
    // consistent about the capital M.
    _guided = (toLower getText (configFile >> "CfgAmmo" >> _ammo >> "simulation")) isEqualTo "shotmissile";

    GVAR(guidedAmmo) set [_ammo, _guided];
};

if (!_guided) exitWith {};

// A projectile that is already null here still gets reported: the receiver falls
// back to marking the threatened unit, which is a better warning than none.
//
// The marker is coloured by whoever is shooting. `side` on the firing vehicle
// resolves through its crew, so it answers for both a soldier with a launcher —
// where _vehicle IS the soldier — and a manned vehicle.
[QGVAR(incoming), [_target, _missile, side _vehicle]] call CBA_fnc_serverEvent;
