#include "script_component.hpp"
/*
 * Author: Maxim
 * Tears down one airstrike, undoing everything FUNC(executeStrike) forced on the
 * aircraft and its driver.
 *
 * The single exit path. Arrival, timeout, the aircraft dying, the driver dying,
 * ownership moving, and a re-order superseding it all route through here — which is
 * the point: a strike leaves an aircraft with three AI features disabled, a CARELESS
 * behaviour and a laser target in the world, and every one of those outlives the
 * strike if any single exit forgets it.
 *
 * The driver restored is the one recorded when the strike STARTED, never
 * `driver _vehicle` re-read now. Those are different units whenever the pilot was
 * killed or swapped mid-run, and restoring the current occupant leaves the real one
 * with MOVE disabled for the rest of the mission with nothing holding a reference to
 * him.
 *
 * EVERY command below takes a LOCAL argument, so teardown only means anything on the
 * machine that owns the piece being torn down. One exit reaches here with that no
 * longer true: FUNC(strikeTick) ends a strike precisely BECAUSE `!local _vehicle`, and
 * running the restores there would be a series of silent no-ops leaving a plane
 * permanently unable to fly itself. So each half is applied where it is local and
 * targeted at its owner where it is not, and the receiving copy is told not to
 * re-route so a split pair cannot ping-pong between two owners forever. Same trap and
 * same fix as EFUNC(slide,endSlide).
 *
 * Arguments:
 * 0: Strike record <ARRAY> - layout in script_component.hpp
 * 1: Route the non-local halves to their owners <BOOL> (default: true)
 *
 * Return Value:
 * None
 *
 * Example:
 * [_record] call rtz_airstrike_fnc_endStrike
 *
 * Public: No
 */

params ["_record", ["_reroute", true]];
_record params ["_vehicle", "_driver"];

// The laser target is not locality-bound the way the aircraft is — whichever machine
// created it can delete it — so it is cleared before anything else and unconditionally.
private _laser = _record select STRIKE_LASER;
if (!isNull _laser) then {
    deleteVehicle _laser;
    _record set [STRIKE_LASER, objNull];
};

private _remote = [];

if (!isNull _vehicle) then {
    if (local _vehicle) then {
        if (alive _vehicle) then {
            // Hand the hull back to physics carrying the velocity it actually has, so
            // it does not stop dead in the air on the frame the rail lets go.
            _vehicle setVelocity (velocity _vehicle);

            // NOT a restore: the engine has no getter for flyInHeight, so there is
            // nothing to restore it to. This is a sane value chosen from where the
            // aircraft ended up, which is what Wargame does for the same reason.
            private _altitude = ((getPos _vehicle) select 2) max FLY_HEIGHT_MIN;
            _vehicle flyInHeight _altitude;
        };
    } else {
        _remote pushBack _vehicle;
    };
};

if (!isNull _driver) then {
    if (local _driver) then {
        (_record select STRIKE_RESTORE) params ["_move", "_target", "_autoTarget", "_behaviour", "_combatMode"];

        // Restored to what was CAPTURED, not blanket-enabled. An aircraft whose AI
        // another RTZ order had already disabled must not come back with it on.
        // Applied even to a dead driver: the flags live on the unit, not on the seat,
        // and a body that gets revived should not come back paralysed.
        if (_move) then {_driver enableAI "MOVE"} else {_driver disableAI "MOVE"};
        if (_target) then {_driver enableAI "TARGET"} else {_driver disableAI "TARGET"};
        if (_autoTarget) then {_driver enableAI "AUTOTARGET"} else {_driver disableAI "AUTOTARGET"};

        if (alive _driver && {!isPlayer _driver}) then {
            _driver setBehaviour _behaviour;
            (group _driver) setCombatMode _combatMode;
        };
    } else {
        _remote pushBackUnique _driver;
    };
};

if (!_reroute || {_remote isEqualTo []}) exitWith {};

// The whole record travels, not just the stranded half: the receiver re-runs this same
// function and picks out whatever IS local to it, so there is no second teardown
// implementation to keep in step with this one.
[QGVAR(release), [_record, false], _remote] call CBA_fnc_targetEvent;
