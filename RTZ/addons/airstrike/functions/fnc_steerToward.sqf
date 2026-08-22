#include "script_component.hpp"
/*
 * Author: Maxim
 * Flies one aircraft one step toward a point, turning no faster than TURN_RATE.
 *
 * This is the whole of the ingress geometry, and it is what replaces Wargame's
 * precomputed approach paths. A target BEHIND the aircraft needs no special case: the
 * yaw error is simply large, so the rotation takes more ticks and the aircraft comes
 * around in an arc. Wargame spends a parabolic path builder, a semicircle turnaround
 * case and fifty interpolated splice points on the same problem.
 *
 * Heading is read from vectorDir rather than getDir, because this function SETS the
 * direction vector every tick and getDir would round-trip it through the engine's yaw
 * and discard the pitch the climb needs.
 *
 * Arguments:
 * 0: Aircraft <OBJECT>
 * 1: Destination ASL <ARRAY>
 * 2: Cruise speed, m/s <NUMBER>
 * 3: Seconds since the previous tick <NUMBER>
 *
 * Return Value:
 * None
 *
 * Example:
 * [_vehicle, _start, _cruise, _delta] call rtz_airstrike_fnc_steerToward
 *
 * Public: No
 */

params ["_vehicle", "_destination", "_cruise", "_delta"];

private _current = vectorDir _vehicle;
private _desired = (getPosASL _vehicle) vectorFromTo _destination;

private _currentYaw = (_current select 0) atan2 (_current select 1);
private _desiredYaw = (_desired select 0) atan2 (_desired select 1);

// Wrapped into (-180, 180] so a target ten degrees to the left is a ten-degree turn
// rather than a three-hundred-and-fifty-degree one. Without the wrap the aircraft
// takes the long way round roughly half the time.
private _error = ((_desiredYaw - _currentYaw + 540) % 360) - 180;

private _maxTurn = TURN_RATE * _delta;
private _turn = (_error max (-_maxTurn)) min _maxTurn;
private _yaw = _currentYaw + _turn;

// Pitch is chased toward the destination and clamped, so a run-in start well above
// the aircraft does not stand it on its tail.
private _pitch = (asin ((_desired select 2) max -1 min 1)) max (-CLIMB_MAX) min CLIMB_MAX;

private _dir = [
    (sin _yaw) * (cos _pitch),
    (cos _yaw) * (cos _pitch),
    sin _pitch
];

_vehicle setVectorDir _dir;

// Bank in proportion to how hard it is ACTUALLY turning, so the model leans into the
// arc instead of sliding around it flat. Guarded against a zero-length tick, which
// happens on the first frame after a hitch.
private _bank = if (_maxTurn > 0) then {-(BANK_MAX * (_turn / _maxTurn))} else {0};

[_vehicle, _pitch, _bank] call BIS_fnc_setPitchBank;

_vehicle setVelocity (_dir vectorMultiply _cruise);
