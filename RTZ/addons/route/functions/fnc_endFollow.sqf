#include "script_component.hpp"
/*
 * Author: Maxim
 * Ends one route and hands its unit back to its group.
 *
 * Restores the unit the RECORD captured, not whoever is at the controls when the
 * route ends. That distinction is the whole reason the unit is carried in the
 * record at all: a driver who swapped seats mid-route ends the route, and
 * releasing the man now in the seat would leave the one this actually stopped
 * standing still for the rest of the mission.
 *
 * doFollow is the exact inverse of the doStop FUNC(startFollow) issued, so the
 * unit resumes whatever its group was doing rather than being given a new order
 * of its own. A unit that is its own leader follows itself, which is the
 * engine's idiom for "resume normal behaviour" and what LAMBS uses to end its
 * own detached-unit tactics.
 *
 * Arguments:
 * 0: Route record <ARRAY>
 *
 * Return Value:
 * None
 *
 * Example:
 * [_record] call rtz_route_fnc_endFollow
 *
 * Public: No
 */

params ["_record"];

_record params ["_unit"];

// Nothing to restore: the unit is gone, dead, or has moved to another machine.
// In the last case the new owner already has it under its own group's control —
// an order from here would do nothing anyway, silently.
if (isNull _unit || {!alive _unit} || {!local _unit}) exitWith {};

_unit doFollow (leader _unit);
