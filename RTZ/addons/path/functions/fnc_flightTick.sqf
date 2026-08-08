#include "script_component.hpp"
/*
 * Author: Maxim
 * Flies or sails one hull one step along its path. Called by FUNC(followTick)
 * for every KIND_AIR and KIND_BOAT record on the scripted executor, on every
 * wake of the shared handler.
 *
 * setDriveOnPath does nothing at all for Air or Ship — it needs an AI steering
 * component neither has — so the choice is between handing the path to the AI as
 * a chain of move orders and moving the hull directly. Wargame moves it
 * directly, and that is the right call: a doMove chain gives the AI a
 * destination and no line, so it picks its own approach, its own altitude and
 * its own speed, and a carefully traced valley run comes out as a straight line
 * over the ridge. This is Wargame's model, with its constants, on this
 * component's cadence.
 *
 * Cadence is where it differs. Wargame runs a per-frame handler PER AIRCRAFT and
 * then throttles the movement inside it to every tenth wake — arriving at
 * roughly six steps a second by way of the most expensive route available. This
 * runs ten times a second on the handler everything else already shares, and the
 * result is not an approximation of the per-frame version: setVelocity persists
 * until something changes it, so between steps the hull is on exactly the
 * trajectory the last step gave it.
 *
 * Four things are computed each step, in this order, because each depends on the
 * one before:
 *
 *  - WHICH LEG. Distance alone is not enough at 90 m/s: a leg can be entered and
 *    left inside one tick, so a hull that has gone PAST the point counts as
 *    having reached it. That is the dot product against the previous position,
 *    and it is why FOLLOW_LAST_POS exists.
 *
 *  - ATTITUDE. The nose follows the direction of travel, pitched by a per-domain
 *    constant so the model leans into it. A plane takes the full 3D direction —
 *    it climbs nose-up, as it should; a helicopter and a boat take the heading
 *    only and lean by their own amount, because a helicopter that pitches with a
 *    steep climb ends up on its back.
 *
 *  - TARGET SPEED. Cruise, scaled down for how hard the path bends within the
 *    next few legs and for how steeply it climbs, and scaled down again over the
 *    last few legs of a helicopter's one-way path so it settles onto its final
 *    point instead of flying through it.
 *
 *  - ACTUAL SPEED, which chases the target rather than jumping to it. A hull
 *    that changed speed instantly would arrive at a corner at cruise and leave
 *    it at a crawl, and read as neither.
 *
 * Arguments:
 * 0: Follow record, mutated in place <ARRAY>
 * 1: Current mission time <NUMBER>
 *
 * Return Value:
 * The path is finished <BOOL>
 *
 * Example:
 * private _done = [_record, _now] call rtz_path_fnc_flightTick
 *
 * Public: No
 */

params ["_record", "_now"];

_record params ["", "_hull", "_points", "_index", "", "_patrol"];
(_record select FOLLOW_FLIGHT) params ["_isHeli", "_isPlane", "_isNaval", "_pitch", "_turnCoef"];

// setVelocity and setVectorDirAndUp only do anything where the HULL is local,
// which is not implied by the driver being local — a vehicle can change hands
// without its crew doing so. Ending the path is the honest outcome: the new
// owner has the vehicle under its own AI and nothing issued here would reach it.
if (!local _hull) exitWith {true};

private _current = getPosASL _hull;

// Still on the ground, still inside the grace. Left entirely alone: the
// flyInHeight FUNC(startFollow) issued is what lifts it, and shoving a hull that
// is still touching the ground only drags it along the runway. Bounded, so an
// aircraft that cannot lift at all is taken over rather than waited on forever
// — see FLIGHT_LIFTOFF_TIME.
if (!_isNaval && {isTouchingGround _hull} && {_now < (_record select FOLLOW_START_AT) + FLIGHT_LIFTOFF_TIME}) exitWith {
    _record set [FOLLOW_LAST_POS, _current];
    false
};

private _count = count _points;
private _arrival = _record select FOLLOW_ARRIVAL;
private _last = _record select FOLLOW_LAST_POS;

// How far the hull actually travelled since the last step. Below a few
// centimetres there is no direction of travel to test against, so the
// passed-the-waypoint test is skipped and distance decides on its own.
private _travelled = _current vectorDiff _last;
private _moving = (vectorMagnitude _travelled) > 0.1;

// Credit every leg already behind or inside the arrival radius, not just one per
// step. A traced corner puts several points within a few metres of each other,
// and a fast hull can be past all of them between two ticks.
private _skips = 0;
while {
    _skips < MAX_SKIP
    && {_index < _count}
    && {
        private _to = (_points select _index) vectorDiff _current;
        (vectorMagnitude _to) <= _arrival || {_moving && {(_travelled vectorDotProduct _to) < 0}}
    }
} do {
    _index = _index + 1;
    _skips = _skips + 1;
};

if (_index >= _count) then {
    if (_patrol) then {_index = 0} else {
        _record set [FOLLOW_INDEX, _count - 1];
        _record set [FOLLOW_LAST_POS, _current];
    };
};

if (_index >= _count) exitWith {true};

_record set [FOLLOW_INDEX, _index];
_record set [FOLLOW_LAST_POS, _current];

private _target = _points select _index;

// ── Attitude ────────────────────────────────────────────────────────────────
private _forward = vectorNormalized (_target vectorDiff _current);

// The horizontal component, which is what an attitude is built from. A
// direction of travel this close to vertical has no heading in it at all — a
// helicopter going straight up — so the hull keeps the heading it already has
// and only its nose moves.
private _heading = vectorNormalized [_forward select 0, _forward select 1, 0];
if (vectorMagnitude _heading < FLIGHT_HEADING_MIN) then {
    _heading = vectorNormalized [(vectorDir _hull) select 0, (vectorDir _hull) select 1, 0];
};

// A boat does not climb. Taking its travel from the heading rather than from the
// full vector is what stops a path traced fractionally above or below the
// waterline from driving it into the air or under it.
if (_isNaval) then {_forward = _heading};

// The lateral axis the pitch is applied about. Wargame's construction, kept
// exactly: this is the hull's LEFT, and rotating the nose about it by a positive
// angle pitches it down — which is why FLIGHT_PITCH_BOAT is negative and a boat
// sits back on its stern.
private _axis = (_heading vectorCrossProduct [0, 0, 1]) vectorMultiply -1;

// A plane's nose follows the full 3D direction of travel; a helicopter's and a
// boat's follow the heading and lean by their own constant instead. A helicopter
// pitched to match a steep climb ends up on its back.
private _dir = [_heading, _forward] select _isPlane;
private _up = _dir vectorCrossProduct _axis;

// ── Speed ───────────────────────────────────────────────────────────────────
private _cruise = _record select FOLLOW_CRUISE;
private _speed = _record select FOLLOW_SPEED;

// How hard the path bends, and how steeply it climbs, within the next few legs.
// Looking AHEAD rather than at the leg being flown is the whole point: a hull
// that starts slowing when it reaches the corner has already missed it.
private _wanted = _cruise;
private _ahead = (_index + FLIGHT_LOOKAHEAD) min (_count - 1);

if (_ahead > _index) then {
    private _legDir = (_points select ((_index - 1) max 0)) getDir _target;
    private _aheadDir = (_points select (_ahead - 1)) getDir (_points select _ahead);

    // Signed difference folded into -180..180, then measured. Without the fold a
    // turn across north reads as 350 degrees rather than 10.
    private _turn = abs ((((_aheadDir - _legDir) + 540) % 360) - 180);

    private _climb = abs ((vectorNormalized ((_points select _ahead) vectorDiff (_points select (_ahead - 1)))) select 2);

    // Whichever of the two costs more speed, not both — a climbing turn is one
    // manoeuvre and charging for it twice stops the hull dead.
    private _score = ((_turn min FLIGHT_TURN_FULL) / FLIGHT_TURN_FULL) max (_climb min 0.8);

    _wanted = _cruise * ((1 - (_score * _turnCoef)) max FLIGHT_SPEED_FLOOR);
};

// Final approach. A helicopter that flies its last leg at cruise overshoots the
// point it was drawn to stop on and has to come back for it, which reads as the
// aircraft having missed rather than as it having arrived.
if (_isHeli && {!_patrol} && {_index >= _count - FLIGHT_FLARE_LEGS}) then {
    _wanted = _wanted min (_cruise * FLIGHT_FLARE_COEF);
    _arrival = _arrival min FLIGHT_FLARE_ARRIVAL;
    _record set [FOLLOW_ARRIVAL, _arrival];
};

// Chased, not jumped to. Deceleration is the faster of the two because arriving
// at a corner over speed loses the line, and arriving under it only costs a
// second on the next straight.
_speed = if (_speed > _wanted) then {
    (_speed - (_cruise * FLIGHT_DECEL)) max _wanted
} else {
    (_speed + (_cruise * FLIGHT_ACCEL)) min _wanted
};

_record set [FOLLOW_SPEED, _speed];

// The lean is applied LAST, and scaled by how fast the hull is actually going.
// Wargame pitches by a flat constant, so its helicopter sits nose-down twenty
// degrees while it is hovering onto a landing point — which is the one moment a
// helicopter is unmistakably level. Scaling it by the fraction of cruise in hand
// costs one multiply and is the difference between a model that leans into its
// travel and one that is simply tilted.
if (_pitch != 0 && {_cruise > 0}) then {
    _dir = [_dir, _axis, _pitch * ((_speed / _cruise) min 1)] call CBA_fnc_vectRotate3D;
};

_hull setVectorDirAndUp [_dir, _up];
_hull setVelocity (_forward vectorMultiply _speed);

false
