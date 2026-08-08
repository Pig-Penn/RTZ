#include "script_component.hpp"
/*
 * Author: Maxim
 * Whether a vehicle can be given (or can keep) a straight-line drive order.
 * The single definition of "drivable this way", shared by the three places that
 * need to agree on it: FUNC(orderSlide) filtering the curator's selection,
 * FUNC(slideTo) re-checking on the owner machine after the network hop, and
 * FUNC(slideTick) deciding whether a running maneuver still has anything to
 * drive.
 *
 * Direction is deliberately not a parameter: nothing here differs between
 * forward and reverse. The engine limitation that forces the setVelocity slide
 * only applies to backing up (see FUNC(slideTo)), but the driver still has to be
 * taken off the navigation stack either way, so the same unit is disabled and
 * the same restore is owed.
 *
 * Static weapons are excluded explicitly rather than left to the driver test.
 * They inherit from LandVehicle and pass canMove, so the config hierarchy is the
 * only thing keeping them out — and disableBrakes is meaningless on something
 * with no wheels either way.
 *
 * Deliberately says nothing about locality: the curator's client evaluates this
 * for vehicles it does not own, and locality is a separate concern checked where
 * the maneuver actually runs.
 *
 * Arguments:
 * 0: Vehicle <OBJECT>
 *
 * Return Value:
 * Vehicle can be driven in a straight line <BOOL>
 *
 * Example:
 * if ([_vehicle] call rtz_slide_fnc_canSlide) then {...};
 *
 * Public: No
 */

params ["_vehicle"];

_vehicle isKindOf "LandVehicle"
&& { !(_vehicle isKindOf "StaticWeapon") }
&& { alive _vehicle }
&& { canMove _vehicle }
&& {
    // A player at the wheel — including a curator remote-controlling the unit,
    // which isPlayer also reports — drives himself; nothing scripted may take
    // the vehicle out from under him.
    private _driver = driver _vehicle;
    !isNull _driver && { alive _driver } && { !isPlayer _driver }
}
