#include "script_component.hpp"
/*
 * Author: Maxim
 * Flies one aircraft one step toward a point, turning, pitching and rolling no faster
 * than TURN_RATE, PITCH_RATE and ROLL_RATE respectively.
 *
 * This is the whole of the ingress geometry, and it is what replaces Wargame's
 * precomputed approach paths. A target BEHIND the aircraft needs no special case: the
 * yaw error is simply large, so the rotation takes more ticks and the aircraft comes
 * around in an arc. Wargame spends a parabolic path builder, a semicircle turnaround
 * case and fifty interpolated splice points on the same problem.
 *
 * ALL THREE AXES ARE RATE-LIMITED, which is the difference between this reading as a
 * flown aircraft and reading as a cursor. Yaw always was; pitch and bank were assigned
 * their target outright, so the nose and the wings teleported between attitudes every
 * time the destination moved. Bank was worse than merely instant: it was taken from
 * `_turn / _maxTurn`, and since `_turn` saturates at `_maxTurn` for any error above a
 * fraction of a degree, that ratio is ±1 through the whole of every turn. The aircraft
 * therefore flew every correction at a hard 60 degrees of roll and snapped level at the
 * end. Bank now comes from the yaw ERROR against BANK_BAND, so it rolls in as the turn
 * begins and rolls out as it finishes.
 *
 * Because both are rate-limited they are STATE, not outputs, and they live on the strike
 * record between ticks — which is why this takes the record rather than the aircraft.
 * They cannot be recovered from the hull each tick: pitch could be read back out of
 * vectorDir, but the commanded bank is not the bank BIS_fnc_setPitchBank left behind
 * once the engine has had its say.
 *
 * Heading is still read from vectorDir rather than getDir, because this function SETS
 * the direction vector every tick and getDir would round-trip it through the engine's
 * yaw and discard the pitch the climb needs.
 *
 * Arguments:
 * 0: Strike record, mutated in place <ARRAY> - layout in script_component.hpp
 * 1: Destination ASL <ARRAY>
 * 2: Seconds since the previous tick <NUMBER>
 *
 * Return Value:
 * None
 *
 * Example:
 * [_record, _carrot, _delta] call rtz_airstrike_fnc_steerToward
 *
 * Public: No
 */

params ["_record", "_destination", "_delta"];

private _vehicle = _record select STRIKE_PLANE;
private _cruise = _record select STRIKE_CRUISE;

private _current = vectorDir _vehicle;
private _desired = (getPosASL _vehicle) vectorFromTo _destination;

private _currentYaw = (_current select 0) atan2 (_current select 1);
private _desiredYaw = (_desired select 0) atan2 (_desired select 1);

// Wrapped into (-180, 180] so a target ten degrees to the left is a ten-degree turn
// rather than a three-hundred-and-fifty-degree one. Without the wrap the aircraft
// takes the long way round roughly half the time.
private _error = ((_desiredYaw - _currentYaw + 540) % 360) - 180;

private _maxTurn = TURN_RATE * _delta;
private _yaw = _currentYaw + ((_error max (-_maxTurn)) min _maxTurn);

// Pitch is CHASED toward the destination at PITCH_RATE rather than assigned, and
// clamped, so a run-in start well above the aircraft neither stands it on its tail nor
// flicks the nose there in one frame.
private _wanted = (asin ((_desired select 2) max -1 min 1)) max (-CLIMB_MAX) min CLIMB_MAX;
private _pitch = _record select STRIKE_PITCH;
private _maxPitch = PITCH_RATE * _delta;
_pitch = _pitch + (((_wanted - _pitch) max (-_maxPitch)) min _maxPitch);

// Bank in proportion to how far off heading it ACTUALLY is, so the model leans into the
// arc as the turn develops and comes level as it ends, then chased at ROLL_RATE so even
// that target is approached rather than jumped to.
private _wantedBank = -(BANK_MAX * (((_error / BANK_BAND) max -1) min 1));
private _bank = _record select STRIKE_BANK;
private _maxRoll = ROLL_RATE * _delta;
_bank = _bank + (((_wantedBank - _bank) max (-_maxRoll)) min _maxRoll);

_record set [STRIKE_PITCH, _pitch];
_record set [STRIKE_BANK, _bank];

private _dir = [
    (sin _yaw) * (cos _pitch),
    (cos _yaw) * (cos _pitch),
    sin _pitch
];

_vehicle setVectorDir _dir;

[_vehicle, _pitch, _bank] call BIS_fnc_setPitchBank;

_vehicle setVelocity (_dir vectorMultiply _cruise);
