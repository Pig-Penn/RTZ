#include "script_component.hpp"
/*
 * Author: Maxim
 * Truncates a path at a point index, dropping that point and everything drawn
 * after it, and puts the drag handle back where the path now ends. An index of
 * 0 empties the path, which is what the reset key does — one operation, not
 * two, because "reset" is only "cut at the beginning".
 *
 * The index is carried through from the renderer's pick rather than recovered by
 * searching the point list. Wargame recovers it with a findIf over an isEqualTo
 * against a stored position, which is a float-equality search that only works
 * because both sides came from the same array in the same frame.
 *
 * Arguments:
 * 0: Unit whose path to cut <OBJECT>
 * 1: Index to cut at; the point AT this index is removed <NUMBER>
 *
 * Return Value:
 * The path was cut <BOOL>
 *
 * Example:
 * [_unit, 12] call rtz_path_fnc_cutPath
 *
 * Public: No
 */

params ["_unit", "_index"];

private _paths = GVAR(paths);
private _pathIndex = _paths findIf {(_x select PATH_UNIT) isEqualTo _unit};
if (_pathIndex == -1) exitWith {false};

private _path = _paths select _pathIndex;
_path params ["", "_hull", "_points"];

private _count = count _points;
if (_count == 0 || {_index >= _count}) exitWith {false};

private _keep = _index max 0;
_points resize _keep;

// Facing spans that started in the removed tail go with it. Backwards and
// breaking at the first survivor: the list is ascending, so this touches only
// what it removes (Gotchas §2 — the test is at the top of the body).
private _spans = _path select PATH_FACING;
for "_s" from (count _spans) - 1 to 0 step -1 do {
    if ((_spans select _s select 0) < _keep) then {break};
    _spans deleteAt _s;
};

// Put the handle back on the new end of the path. An emptied path hands it
// back to the subject itself, which is where FUNC(beginPlanning) started it.
if (_points isEqualTo []) then {
    _path set [PATH_HEAD, getPosASL _hull];
    _path set [PATH_DIR, getDir _hull];
} else {
    private _last = _points select -1;
    // Heading of the final leg: from whatever precedes the new end — the point
    // before it, or the subject when the path is down to a single point. The
    // negative index is only ever reached with two points in hand.
    private _prior = if (count _points > 1) then {
        _points select -2
    } else {
        getPosASL _hull
    };
    _path set [PATH_HEAD, _last];
    _path set [PATH_DIR, _prior getDir _last];
};

// The head moved, so an aircraft's altitude readout is stale
if ((_path select PATH_KIND) == KIND_AIR) then {
    _path set [PATH_ALT, format ["%1 m", round ((ASLToAGL (_path select PATH_HEAD)) select 2)]];
};

// An outstanding auto-path search was computed from a head this cut has just
// removed. FUNC(splicePath)'s point-count guard would reject it anyway in every
// ordinary case — but a curator who cuts and then re-draws back to the same
// length would slip through it, so retire the search outright.
_path set [PATH_SEARCH, []];

// The pick that drove this cut is stale the moment the points move
GVAR(hoveredPoint) = [];

true
