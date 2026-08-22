#include "script_component.hpp"
/*
 * Author: Maxim
 * Resolves a curator selection to the single aircraft an airstrike can be ordered
 * on, or objNull if the selection is not one this order can serve.
 *
 * One function rather than the same gate written at three call sites — the context
 * condition, the submenu builder and the order itself all ask exactly this question,
 * and three copies of it would drift.
 *
 * The selection is normalized through EFUNC(common,collectVehicles) so that clicking
 * a crewman orders the aircraft he is riding in, matching every other RTZ vehicle
 * order.
 *
 * Arguments:
 * 0: Selected objects <ARRAY>
 *
 * Return Value:
 * The aircraft, or objNull <OBJECT>
 *
 * Example:
 * private _plane = [_objects] call rtz_airstrike_fnc_strikeAircraft
 *
 * Public: No
 */

params ["_objects"];

private _vehicles = [_objects] call EFUNC(common,collectVehicles);

// EXACTLY one. Two aircraft is not a selection this order can serve, and picking one
// of them silently is worse than showing no button at all: the curator would watch
// the wrong jet roll in and have no way to tell why.
if (count _vehicles != 1) exitWith {objNull};

private _vehicle = _vehicles select 0;

// Planes only in v1. Helicopters are rejected HERE rather than half-supported
// downstream, because their flight profile is genuinely different and a heli flown
// on the plane rail looks broken rather than merely wrong.
if !(_vehicle isKindOf "Plane") exitWith {objNull};
if (!alive _vehicle) exitWith {objNull};

// On the deck there is no run-in to fly.
if (isTouchingGround _vehicle) exitWith {objNull};

private _driver = driver _vehicle;
if (isNull _driver) exitWith {objNull};
if (!alive _driver) exitWith {objNull};
if (isPlayer _driver) exitWith {objNull};

if (([_vehicle] call FUNC(strikeWeapons)) isEqualTo []) exitWith {objNull};

_vehicle
