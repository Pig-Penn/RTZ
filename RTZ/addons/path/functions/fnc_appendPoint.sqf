#include "script_component.hpp"
/*
 * Author: Maxim
 * Offers one cursor sample to a path. Most samples are refused — the cursor
 * moves further in a frame than it moves in metres — and refusing is the normal
 * outcome, not an error.
 *
 * The gates run cheapest-first, which is the whole reason this is affordable at
 * frame rate: three arithmetic tests reject the overwhelming majority of samples
 * before anything casts a ray. Wargame does the same work in the opposite order
 * and pays for eight downward rays on samples it then throws away.
 *
 * There is deliberately no gap interpolation. Wargame fills a fast cursor sweep
 * with intermediate points because its executor walks the polyline literally;
 * RTZ hands each leg to the AI's own navigation, so a straight 30 m leg IS what
 * was traced and inventing five points inside it would only cost memory. The
 * line test already covers the whole segment either way.
 *
 * Arguments:
 * 0: Path record, mutated in place <ARRAY>
 * 1: Candidate position, ASL <ARRAY>
 *
 * Return Value:
 * The point was appended <BOOL>
 *
 * Example:
 * [_path, _cursorASL] call rtz_path_fnc_appendPoint
 *
 * Public: No
 */

params ["_path", "_target"];

_path params ["", "_hull", "_points", "", "_kind", "_head"];

private _profile = GVAR(profiles) select _kind;

// Bounded. A path that has run out of length simply stops growing; the drawn
// line stopping where it stopped is its own explanation.
if (count _points >= (_profile select PROF_MAX_POINTS)) exitWith {false};

// Road magnetisation, before anything is measured — the point that gets gated is
// the point that will be kept
private _snapped = false;
if (_kind == KIND_LAND && {GVAR(mods) select 0}) then {
    // Read out by hand rather than with `params`. `params` declares its
    // variables PRIVATE TO THE CURRENT SCOPE, and the current scope inside a
    // `then` block is that block — so it would shadow the two variables here
    // and throw the result away the moment the block ended. Plain assignment
    // reaches the outer ones.
    private _snap = [_target, _head] call FUNC(snapToRoad);
    _target = _snap select 0;
    _snapped = _snap select 1;
};

// A snapped point has already passed the only test that matters for it
private _accepted = _snapped;

private _distance = _head distance _target;

private _spacing = _profile select PROF_SPACING;

// A mostly-vertical sample is a deliberate altitude change, and is measured in
// metres rather than in the tens of metres a traverse is traced at. Without
// this, setting a height would take a 25 m climb before the first point landed.
private _climb = (_target select 2) - (_head select 2);
if (_kind == KIND_AIR && {abs _climb > (_distance * AIR_CLIMB_RATIO)}) then {
    _spacing = AIR_CLIMB_SPACING;
};

// Not far enough to be a new point yet — the ordinary answer, several times a
// second, for a cursor that is barely moving
if (_distance < _spacing) exitWith {false};

// Too far to have been traced. A cursor swept across a ridge resolves onto a
// hillside hundreds of metres away between one frame and the next, and the leg
// that would create was never drawn by anyone.
if (_distance > MAX_SEGMENT) exitWith {false};

// The terrain gates are skipped for a point pulled onto a road. Roads
// legitimately climb gradients that would read as a wall if the same rise were
// traced across open ground, and a road is by definition somewhere a vehicle
// can already be.
if (!_snapped) then {
    // Climbing more than the subject can climb: a wall, a rooftop, a cliff edge
    if (_climb > (_profile select PROF_MAX_CLIMB)) exitWith {};

    // Same rejection expressed as steepness rather than height, which catches
    // the short-but-vertical case the climb gate lets through
    if (((_head vectorFromTo _target) select 2) > (_profile select PROF_MAX_INCLINE)) exitWith {};

    if !([_head, _target, _hull, _kind, _profile] call FUNC(validatePoint)) exitWith {
        // Blocked. Rather than stall against the wall, ask the engine for a way
        // through; the path continues on its own once the answer arrives
        // (FUNC(splicePath)).
        [_path, _target] call FUNC(autoPath);
    };

    _accepted = true;
};

// `exitWith` inside the block above unwinds only that block, so this is what
// actually turns a failed gate into a refused sample. Declared before it,
// seeded true for a snapped point because those skipped the gates entirely.
if (!_accepted) exitWith {false};

// The curator got past the obstruction by hand, so whatever the engine is still
// computing is about a head that no longer exists. Retiring the search here does
// two things: it frees the path to ask again at the NEXT obstruction rather than
// waiting out AUTOPATH_TIMEOUT, and it is the earliest point at which the answer
// becomes stale. Wargame cancels in the same place, for the first reason.
_path set [PATH_SEARCH, []];

// May drop points off the tail and move PATH_HEAD backwards with them, so the
// heading below is read AFTER it rather than from the head captured above.
// _points is a reference to the same array it resizes, so the pushBack that
// follows still lands on the right one.
[_path, _target, _profile] call FUNC(smoothTail);

_points pushBack _target;

// Alt marks this stretch of path as a TACTICAL move: the subject walks it facing
// a fixed direction instead of facing the way it is going. Infantry only — Alt
// already means fine altitude on an air path, and a vehicle cannot strafe.
private _tactical = _kind == KIND_INFANTRY
    && {GVAR(mods) select 2}
    && {GETGVAR(infantryExecutor,EXEC_SCRIPTED) != EXEC_AI};

// PATH_DIR is the handle's heading, and it is also the direction a tactical
// stretch is walked facing. Alt simply FREEZES it rather than setting anything:
// the handle visibly stops turning to follow the line, which is the feedback
// that the facing is now locked, and it holds whatever the last travel heading
// or Shift-rotation (FUNC(handleInput)) left it at. One variable doing both jobs
// is Wargame's trick and it is a good one.
if (!_tactical) then {
    _path set [PATH_DIR, (_path select PATH_HEAD) getDir _target];
};

_path set [PATH_HEAD, _target];

// Record the CHANGE, not the state — one pair when the lock goes on and one when
// it comes off, however many hundred points are drawn in between. Within a
// single drag the azimuth cannot drift (rotation is a different gesture and is
// latched at mouse-down), so comparing the two directly is comparing numbers
// that came from the same assignment rather than two float derivations.
if (_kind == KIND_INFANTRY) then {
    private _spans = _path select PATH_FACING;
    private _want = [FACING_NONE, _path select PATH_DIR] select _tactical;

    private _have = FACING_NONE;
    if (_spans isNotEqualTo []) then {_have = (_spans select -1) select 1};

    if (_want != _have) then {
        _spans pushBack [(count _points) - 1, _want];
    };
};

// The altitude readout is built HERE, where the altitude changes, so neither
// renderer ever formats a number per handle per frame
if (_kind == KIND_AIR) then {
    _path set [PATH_ALT, format ["%1 m", round ((ASLToAGL _target) select 2)]];

    // The head has just moved to the altitude the drag earned, so the
    // accumulator that carried it there (FUNC(airTarget)) starts again from
    // here — leaving it standing would apply the same climb a second time.
    GVAR(altDrag) = 0;
};

// Everything else in the selection follows this path, a fixed distance behind,
// so a column is one gesture rather than six
if (GETGVAR(formationTrail,true) && {(_path select PATH_UNIT) isEqualTo GVAR(grabbed)}) then {
    [_path] call FUNC(formationTrail);
};

true
