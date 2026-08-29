#include "script_component.hpp"
/*
 * Author: Maxim
 * Tears down one straight-line drive, undoing everything FUNC(slideTo) forced on
 * the vehicle and its driver.
 *
 * The single exit path. Every way a maneuver can end — arrival, timeout, stuck,
 * wrecked, immobilised, driver lost, ownership moved, superseded by a new order
 * — routes through here, which is the point: a slide leaves two pieces of sticky
 * state behind it (a driver with MOVE/PATH disabled, a vehicle with its parking
 * brake released) and both outlive the maneuver if any single exit forgets them.
 * Concentrating teardown in one function is what makes that impossible rather
 * than merely unlikely.
 *
 * The driver released is the one recorded when the maneuver STARTED, never
 * `driver _vehicle` re-read now. Those are different units whenever the driver
 * was killed, ejected or swapped mid-slide, and releasing the current occupant
 * leaves the real one immobile for the rest of the mission with nothing left
 * holding a reference to him. He is released even when dead or no longer aboard,
 * for the same reason — the flags are on the unit, not on the seat, and a body
 * that gets revived should not come back paralysed.
 *
 * EVERY command below takes a LOCAL argument — setVelocity, disableBrakes,
 * enableAI and doFollow alike — so teardown only means anything on the machine
 * that owns the piece being torn down. One exit reaches here with that no longer
 * true: FUNC(slideTick) ends a maneuver precisely BECAUSE `!local _vehicle`, and
 * running the restores there would have been four silent no-ops. The brake is the
 * one that bites — it was released by the old owner and, unreleased, leaves the
 * hulk free-rolling for the rest of the mission, which is the exact failure the
 * comment below warns about. Same locality trap, and the same fix, as
 * EFUNC(supply,applyService).
 *
 * So each half is applied where it is local and targeted at its owner where it is
 * not. The vehicle and its driver are normally the same machine and the common
 * path costs no network traffic at all; they separate only when a player has taken
 * the seat, or mid-handover. The receiving copy is told NOT to re-route (_reroute
 * false): vehicle-here / driver-there would otherwise bounce the event back and
 * forth between the two owners forever.
 *
 * Arguments:
 * 0: Maneuver record <ARRAY> - layout in script_component.hpp
 * 1: Route the non-local halves to their owners <BOOL> (default: true; the
 *    QGVAR(release) handler passes false so a split pair cannot ping-pong)
 *
 * Return Value:
 * None
 *
 * Example:
 * [_record] call rtz_slide_fnc_endSlide
 *
 * Public: No
 */

params ["_record", ["_reroute", true]];
_record params ["_vehicle", "_driver"];

// Collected before anything is applied, so the send reflects the state the
// maneuver actually ended in rather than one half of a teardown in progress.
private _remote = [];

if (!isNull _vehicle) then {
    if (local _vehicle) then {
        // Kill the horizontal slide, leaving the vertical component to physics so a
        // vehicle that ended the maneuver on a slope or in mid-air still falls
        if (alive _vehicle) then {
            _vehicle setVelocity [0, 0, (velocity _vehicle) select 2];
        };

        // Re-arm the parking brake even on a wreck: disableBrakes is a property of
        // the object, not of the maneuver, and a hulk left with its brakes off rolls
        // freely off the first slope it is nudged onto
        _vehicle disableBrakes false;
    } else {
        _remote pushBack _vehicle;
    };
};

if (!isNull _driver) then {
    if (local _driver) then {
        _driver enableAI "MOVE";
        _driver enableAI "PATH";

        // Cancel the doStop that took him off the navigation stack. Only meaningful
        // for a live AI still able to take orders; a player who has since occupied
        // the seat gives his own.
        if (alive _driver && { !isPlayer _driver }) then {
            _driver doFollow (leader _driver);
        };
    } else {
        _remote pushBackUnique _driver;
    };
};

if (!_reroute || {_remote isEqualTo []}) exitWith {};

// The whole record travels, not just the stranded half: the receiver re-runs this
// same function and picks out whatever IS local to it, so there is no second
// teardown implementation to keep in step with this one.
[QGVAR(release), [_record, false], _remote] call CBA_fnc_targetEvent;
