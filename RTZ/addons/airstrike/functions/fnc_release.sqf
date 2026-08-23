#include "script_component.hpp"
/*
 * Author: Maxim
 * Runs the firing window of one attack run: creates the mark, points the aircraft at
 * it, and pulls the trigger on a cadence until the window closes.
 *
 * The invisible laser target is the whole trick, and it is ZEN's CAS module's. The AI
 * will not engage bare coordinates — fireAtTarget needs something to aim at — but it
 * will engage a laser target sitting on them. Wargame solves the same problem the hard
 * way, by re-guiding every projectile in a FiredMan handler; that is the upgrade path
 * for accuracy, and this function is separate precisely so it can be taken without
 * touching the engine.
 *
 * Kept OUT of the rail's own case in FUNC(strikeTick) even though it runs inside the
 * run phase, because it owns five fields of the record and inlining it would make the
 * rail's case the longest thing in the component.
 *
 * Arguments:
 * 0: Strike record, mutated in place <ARRAY>
 * 1: Current mission time <NUMBER>
 *
 * Return Value:
 * The firing window is finished <BOOL>
 *
 * Example:
 * private _done = [_record, _now] call rtz_airstrike_fnc_release
 *
 * Public: No
 */

params ["_record", "_now"];

_record params ["_vehicle", "_driver", "_aim"];
(_record select STRIKE_WEAPON) params ["_weapon"];

private _laser = _record select STRIKE_LASER;

// First call for this strike: plant the mark and hand the aircraft its target.
if (isNull _laser) then {
    private _side = side (group _driver);
    private _class = ["LaserTargetE", "LaserTargetW"] select (_side getFriend west > 0.6);

    // "NONE" so it is not snapped to the terrain and is not registered as curator
    // editable — a curator who could select and delete the mark could break the strike
    // he had just ordered, without any way to see why.
    _laser = createVehicle [_class, ASLToAGL _aim, [], 0, "NONE"];
    _laser setPosASL _aim;

    _record set [STRIKE_LASER, _laser];
    _record set [STRIKE_FIRE_END, _now + FIRE_DURATION];

    // reveal/doWatch/doTarget take the EMITTER's laser target, while fireAtTarget takes
    // the emitter object itself. That asymmetry is ZEN's, and it is reproduced rather
    // than tidied because it is the combination known to work.
    _vehicle reveal (laserTarget _laser);
    _driver doWatch (laserTarget _laser);
    _driver doTarget (laserTarget _laser);
};

if (_now >= (_record select STRIKE_NEXTFIRE)) then {
    _vehicle fireAtTarget [_laser, _weapon];

    _record set [STRIKE_NEXTFIRE, _now + FIRE_DELAY];
    _record set [STRIKE_SHOTS, (_record select STRIKE_SHOTS) + 1];
};

private _fireEnd = _record select STRIKE_FIRE_END;

// Drives the rail's aim raise. Rising from 0 to 1 across the window is what walks the
// impacts forward instead of piling them on one spot.
_record set [STRIKE_PROGRESS, ((1 - ((_fireEnd - _now) / FIRE_DURATION)) max 0) min 1];

// A lock-based launcher hammered at 10 Hz empties its whole pylon into a single point,
// so guided weapons fire once and are done.
private _guided = getNumber (configFile >> "CfgWeapons" >> _weapon >> "weaponLockSystem") != 0;
private _cap = [MAX_SHOTS, 1] select _guided;

_now >= _fireEnd
    || {(_record select STRIKE_SHOTS) >= _cap}
    || {_vehicle ammo _weapon <= 0}
