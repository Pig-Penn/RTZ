#include "script_component.hpp"
/*
 * Author: Maxim
 * Receives the engine's answer to a FUNC(autoPath) search and appends it to the
 * path that asked for it.
 *
 * Everything about the path is re-established here rather than trusted from the
 * request. A calculatePath search takes long enough that the session can have
 * been committed, cancelled or restarted in the meantime, and the unit can have
 * been killed or driven off — so the record is looked up again by unit, and a
 * path that is no longer in the session is simply dropped. State goes stale
 * across a suspension; re-validate after it, never only before (Gotchas §1).
 *
 * The path being LIVE is not enough: it has to be the same path. A detour is
 * computed from the head the search was asked about, and the curator can drag on
 * past the obstruction for the whole of AUTOPATH_TIMEOUT — so an answer arriving
 * after that would splice on as a leg jumping backwards through everything drawn
 * in between. The point count recorded at request time (PATH_SEARCH) is what
 * catches it. Wargame guards the same window by comparing the head position.
 *
 * The engine's path is far denser than a traced one, so it is resampled to this
 * path's own spacing on the way in — otherwise one drag through a doorway would
 * spend a quarter of the path's entire point budget.
 *
 * Each resampled leg is then re-validated, and the splice stops at the first one
 * that fails. calculatePath is asked for a generic "man" or "wheeled_APC" agent
 * rather than for the hull, and it answers at terrain level rather than at this
 * path's own PROF_CLEAR_HEIGHT — so the route it returns is a suggestion, not a
 * guarantee, and taking it on trust is how a tank ends up spliced through a wall
 * a wheeled APC would have fitted past. Wargame re-runs the same check between
 * consecutive points for the same reason.
 *
 * Arguments:
 * 0: Path record as it was when the search started <ARRAY>
 * 1: Path from the PathCalculated event, ASL <ARRAY>
 *
 * Return Value:
 * Points were spliced in <BOOL>
 *
 * Example:
 * [_record, _calculated] call rtz_path_fnc_splicePath
 *
 * Public: No
 */

params ["_path", "_calculated"];

if (!GVAR(planning) || {_calculated isEqualTo []} || {count _calculated < 2}) exitWith {false};

// The session may have turned over entirely while the engine worked, so the
// record that matters is whichever one is live for this unit NOW
private _unit = _path select PATH_UNIT;
private _index = GVAR(paths) findIf {(_x select PATH_UNIT) isEqualTo _unit};
if (_index == -1) exitWith {false};

private _live = GVAR(paths) select _index;

// Read BEFORE it is cleared: the count this search was asked about
private _requestedAt = (_live select PATH_SEARCH) param [1, -1];
_live set [PATH_SEARCH, []];

private _kind = _live select PATH_KIND;
private _profile = GVAR(profiles) select _kind;
private _points = _live select PATH_POINTS;
private _limit = _profile select PROF_MAX_POINTS;

// The curator drew on past the obstruction while the engine worked, so the head
// this detour was computed from is no longer the head it would attach to
if (count _points != _requestedAt) exitWith {false};

private _hull = _live select PATH_HULL;

// The engine samples far finer than a traced path does. Only the points are
// wanted here — the kept indices refer to the ENGINE's array, which nothing
// downstream of this has, and the facing spans this path already carries are
// indexed against its own points and are unaffected by an append.
private _legs = ([_calculated, _profile select PROF_SPACING] call FUNC(reducePath)) select 0;

private _added = false;
private _from = _live select PATH_HEAD;

{
    // Tested at the TOP of the body: a `break` at the bottom still pays for the
    // whole iteration it is meant to skip (Gotchas §2).
    if (count _points >= _limit) then {break};

    // The pathfinder was given the head as its start, so its first point sits on
    // top of one the path already has
    if (_forEachIndex == 0) then {continue};

    // The engine's answer is a suggestion for a generic agent at terrain level,
    // not a guarantee for this hull at this path's clearance height. Stop at the
    // first leg that does not hold rather than splicing the rest of a route that
    // has already left the drivable world.
    if !([_from, _x, _hull, _kind, _profile] call FUNC(validatePoint)) then {break};

    _points pushBack _x;
    _from = _x;
    _added = true;
} forEach _legs;

if (!_added) exitWith {false};

private _last = _points select -1;
private _prior = if (count _points > 1) then {_points select -2} else {getPosASL (_live select PATH_HULL)};

_live set [PATH_DIR, _prior getDir _last];
_live set [PATH_HEAD, _last];

if ((_live select PATH_KIND) == KIND_AIR) then {
    _live set [PATH_ALT, format ["%1 m", round ((ASLToAGL _last) select 2)]];
};

true
