#include "script_component.hpp"
/*
 * Author: Maxim
 * Decides whether a puppet should stop walking its path and fight, keeps the
 * engagement pointed while it lasts, and ends it. Runs on the record's
 * half-second stagger, never per frame.
 *
 * This is the answer to the one real objection to the scripted infantry
 * executor. A unit with MOVE and ANIM disabled is not looking for anything and
 * cannot break contact, so without this it walks through a firefight, and that
 * is exactly how Wargame's executor behaves for anyone who does not port its
 * combat helper. Wargame does have one; what it does not have is a bound on it.
 *
 * Pausing is done by LEAVING the executor outright rather than by holding a flag
 * inside it: FUNC(setPuppet) with "" hands the unit its AI, its animation and
 * its aim back in one call, and resuming is the tick's ordinary "walk this leg"
 * path re-entering. That is two event handlers rebuilt per engagement and
 * nothing else, and it means there is exactly ONE description of what it is to
 * be a puppet rather than one for walking and a second for walking-but-paused.
 * Wargame carries the second, with its own disableAI calls, and that duplication
 * is where its resume loop can strand a unit with MOVE off.
 *
 * Three things end an engagement, and the last is the one Wargame lacks: the
 * target dies or is lost to sight or range, the path is abandoned, or
 * ENGAGE_MAX_TIME runs out. A unit that can see a target it cannot resolve —
 * behind glass, across a river, armoured — otherwise never walks again.
 *
 * FOLLOW_ENGAGE_AT carries two clocks, told apart by FOLLOW_TARGET: while a
 * target is held it is the deadline that engagement must end by, and while none
 * is it is the earliest the unit may break off again. One field because they can
 * never be live at the same time, and a cooldown is what stops a target
 * flickering in and out of sight from stopping and starting the puppet several
 * times a second.
 *
 * Arguments:
 * 0: Follow record, mutated in place <ARRAY>
 * 1: Current mission time <NUMBER>
 *
 * Return Value:
 * The unit is engaging and must not be walked this tick <BOOL>
 *
 * Example:
 * if ([_record, _now] call rtz_path_fnc_combatPause) then {continue};
 *
 * Public: No
 */

params ["_record", "_now"];

private _unit = _record select FOLLOW_UNIT;
private _target = _record select FOLLOW_TARGET;

// How far this man has any business breaking off for, given what is in his
// hands. A launcher or an empty pair of hands is not a reason to stop walking
// unless the threat is on top of him — Wargame's rule, and very nearly its
// numbers.
private _current = currentWeapon _unit;
private _slot = [primaryWeapon _unit, handgunWeapon _unit, secondaryWeapon _unit] findIf {_x == _current};
private _range = switch (_slot) do {
    case 0: {ENGAGE_RANGE_RIFLE};
    case 1: {ENGAGE_RANGE_PISTOL};
    default {ENGAGE_RANGE_NONE};
};

// Already fighting: keep it pointed, and decide whether it is over
if (!isNull _target) exitWith {
    private _over = !alive _target
        || {_now > (_record select FOLLOW_ENGAGE_AT)}
        || {_unit distance _target > _range}
        || {(lineIntersectsSurfaces [eyePos _unit, aimPos _target, _unit, _target, true, 1, "GEOM", "VIEW"]) isNotEqualTo []};

    if (!_over) exitWith {
        // Re-asserted each stagger rather than once at the start, because the AI
        // drops a manual target as soon as it thinks the engagement is finished
        // and a puppet that has been handed its AI back has nothing else telling
        // it what to shoot at.
        _unit doWatch _target;
        _unit doTarget _target;
        _unit doFire _target;
        true
    };

    // Over. The deadline field becomes the cooldown, and the walk resumes on the
    // tick's ordinary path — which re-enters FUNC(setPuppet) because
    // FOLLOW_ANIM is "" again.
    _record set [FOLLOW_TARGET, objNull];
    _record set [FOLLOW_ENGAGE_AT, _now + ENGAGE_COOLDOWN];

    _unit doWatch objNull;
    _unit doTarget objNull;

    false
};

// Not fighting, and not allowed to start yet
if (_now < (_record select FOLLOW_ENGAGE_AT)) exitWith {false};

// A group told not to fight does not stop walking to fight. Checked here rather
// than at commit, because a curator can put the selection on Careless while the
// path is running and expect it to be obeyed.
if ((behaviour _unit) isEqualTo "CARELESS") exitWith {false};

// Whoever last shot him, if that is still worth answering, else the nearest
// enemy his GROUP already knows about. Reading the remembered instigator first
// is what makes a puppet respond to fire from a direction it was not looking in;
// consuming it unconditionally is what stops a single hit from a unit that has
// since died being retried on every stagger for the rest of the path.
private _threat = _unit getVariable [QGVAR(threat), objNull];
_unit setVariable [QGVAR(threat), nil];

if (isNull _threat || {!alive _threat} || {_unit distance _threat > _range}) then {
    // Engine-side and cheap: this asks what the unit's side already knows rather
    // than sweeping the map. It can answer with something the unit cannot
    // actually see, which is what the line test below is for.
    _threat = _unit findNearestEnemy _unit;
};

if (isNull _threat || {!alive _threat}) exitWith {false};
if (_unit distance _threat > _range) exitWith {false};
if ((lineIntersectsSurfaces [eyePos _unit, aimPos _threat, _unit, _threat, true, 1, "GEOM", "VIEW"]) isNotEqualTo []) exitWith {false};

// Hand everything back before the engagement rather than layering an
// enableAI on top of the puppet: one description of the state, entered and left
// through one function.
[_record, ""] call FUNC(setPuppet);

_record set [FOLLOW_TARGET, _threat];
_record set [FOLLOW_ENGAGE_AT, _now + ENGAGE_MAX_TIME];

_unit reveal [_threat, 4];
_unit doWatch _threat;
_unit doTarget _threat;
_unit doFire _threat;

true
