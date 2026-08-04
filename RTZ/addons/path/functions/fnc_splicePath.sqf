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
 * The engine's path is far denser than a traced one, so it is resampled to this
 * path's own spacing on the way in — otherwise one drag through a doorway would
 * spend a quarter of the path's entire point budget.
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
_live set [PATH_SEARCH, 0];

private _profile = GVAR(profiles) select (_live select PATH_KIND);
private _points = _live select PATH_POINTS;
private _limit = _profile select PROF_MAX_POINTS;

// The engine samples far finer than a traced path does
private _legs = [_calculated, _profile select PROF_SPACING] call FUNC(reducePath);

private _added = false;
{
    if (count _points >= _limit) then {break};

    // The pathfinder was given the head as its start, so its first point sits on
    // top of one the path already has
    if (_forEachIndex == 0) then {continue};

    _points pushBack _x;
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
