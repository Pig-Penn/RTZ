#include "script_component.hpp"
/*
 * Author: Maxim
 * Tears down one reverse maneuver, undoing everything FUNC(reverseTo) forced on
 * the vehicle and its driver.
 *
 * The single exit path. Every way a maneuver can end — arrival, timeout, stuck,
 * wrecked, immobilised, driver lost, ownership moved, superseded by a new order
 * — routes through here, which is the point: a reverse leaves two pieces of
 * sticky state behind it (a driver with MOVE/PATH disabled, a vehicle with its
 * parking brake released) and both outlive the maneuver if any single exit
 * forgets them. Concentrating teardown in one function is what makes that
 * impossible rather than merely unlikely.
 *
 * The driver released is the one recorded when the maneuver STARTED, never
 * `driver _vehicle` re-read now. Those are different units whenever the driver
 * was killed, ejected or swapped mid-slide, and releasing the current occupant
 * leaves the real one immobile for the rest of the mission with nothing left
 * holding a reference to him. He is released even when dead or no longer aboard,
 * for the same reason — the flags are on the unit, not on the seat, and a body
 * that gets revived should not come back paralysed.
 *
 * Arguments:
 * 0: Maneuver record <ARRAY> - layout in script_component.hpp
 *
 * Return Value:
 * None
 *
 * Example:
 * [_record] call rtz_reverse_fnc_endReverse
 *
 * Public: No
 */

params ["_record"];
_record params ["_vehicle", "_driver"];

if (!isNull _vehicle) then {
    // Kill the horizontal slide, leaving the vertical component to physics so a
    // vehicle that ended the maneuver on a slope or in mid-air still falls
    if (alive _vehicle) then {
        _vehicle setVelocity [0, 0, (velocity _vehicle) select 2];
    };

    // Re-arm the parking brake even on a wreck: disableBrakes is a property of
    // the object, not of the maneuver, and a hulk left with its brakes off rolls
    // freely off the first slope it is nudged onto
    _vehicle disableBrakes false;
};

if (!isNull _driver) then {
    _driver enableAI "MOVE";
    _driver enableAI "PATH";

    // Cancel the doStop that took him off the navigation stack. Only meaningful
    // for a live AI still able to take orders; a player who has since occupied
    // the seat gives his own.
    if (alive _driver && { !isPlayer _driver }) then {
        _driver doFollow (leader _driver);
    };
};
