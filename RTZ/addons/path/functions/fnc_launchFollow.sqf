#include "script_component.hpp"
/*
 * Author: Maxim
 * Issues a path's FIRST order. Called once per record by FUNC(followTick), on
 * the first tick at or after FOLLOW_START_AT.
 *
 * Separated from FUNC(startFollow) rather than done there for two reasons.
 * Wargame waits between tearing down a unit's previous scripted move and
 * starting the next, and warns that not doing so "causes weird behaviour" — a
 * settle that costs a spawn or a waitAndExecute per order if the launch happens
 * at commit, and nothing at all if it happens on a tick that was going to run
 * anyway. And the tick has already re-checked that the unit is alive, local and
 * still in its seat, which the commit event cannot do for a moment 0.25 s in the
 * future.
 *
 * A scripted infantry path launches into NOTHING here: the puppet is entered by
 * the tick's ordinary "walk this leg" path, which is also where it re-enters
 * after every combat pause, so there is one description of how a man is put on
 * an animation rather than two.
 *
 * Arguments:
 * 0: Follow record, mutated in place <ARRAY>
 *
 * Return Value:
 * None
 *
 * Example:
 * [_record] call rtz_path_fnc_launchFollow
 *
 * Public: No
 */

params ["_record"];

_record params ["_unit", "_hull", "_points", "", "_kind"];

_record set [FOLLOW_LAUNCHED, true];

// The engine drives from here; there is no ongoing work at all
if (_kind == KIND_LAND) exitWith {
    _hull setDriveOnPath (_record select FOLLOW_DRIVE);
};

private _first = ASLToAGL (_points select 0);

// A scripted man is put on his animation by the tick, not here
if (_kind == KIND_INFANTRY) exitWith {
    if (!(_record select FOLLOW_SCRIPTED)) then {
        _unit doMove _first;
    };
};

// Aircraft and boats, on either executor, need the engine running, and anything
// that flies needs a height to climb to. On the scripted executor that climb is
// the only thing lifting the aircraft off the ground under its own power:
// FUNC(flightTick) deliberately leaves a hull that is still touching ground
// alone, because shoving one that is only drags it down the runway.
_hull engineOn true;

if (_kind == KIND_AIR) then {
    _hull flyInHeight (_first select 2);
};

// The first leg of the chain — and ONLY on the AI executor. A scripted hull is
// deliberately given no destination at all: an AI pilot with one flies the
// aircraft as hard as the model does, in a direction of its own, for the whole
// route, and the two fight each other visibly. The one thing a move order buys
// is a keener liftoff, and liftoff is bounded anyway — FLIGHT_LIFTOFF_TIME hands
// the aircraft to the model, whose first leg is above it, so the velocity it
// applies lifts it regardless.
if (!(_record select FOLLOW_SCRIPTED)) then {
    _unit doMove _first;
};
