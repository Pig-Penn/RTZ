#include "script_component.hpp"
/*
 * Author: Maxim
 * Truncates a route at a point index, dropping that point and everything drawn
 * after it, and puts the drag handle back where the route now ends. An index of
 * 0 empties the route, which is what the reset key does — one operation, not
 * two, because "reset" is only "cut at the beginning".
 *
 * The index is carried through from the renderer's pick rather than recovered by
 * searching the point list. Wargame recovers it with a findIf over an isEqualTo
 * against a stored position, which is a float-equality search that only works
 * because both sides came from the same array in the same frame.
 *
 * Arguments:
 * 0: Unit whose route to cut <OBJECT>
 * 1: Index to cut at; the point AT this index is removed <NUMBER>
 *
 * Return Value:
 * The route was cut <BOOL>
 *
 * Example:
 * [_unit, 12] call rtz_route_fnc_cutRoute
 *
 * Public: No
 */

params ["_unit", "_index"];

private _routes = GVAR(routes);
private _routeIndex = _routes findIf {(_x select ROUTE_UNIT) isEqualTo _unit};
if (_routeIndex == -1) exitWith {false};

private _route = _routes select _routeIndex;
_route params ["", "_hull", "_points"];

private _count = count _points;
if (_count == 0 || {_index >= _count}) exitWith {false};

_points resize (_index max 0);

// Put the handle back on the new end of the route. An emptied route hands it
// back to the subject itself, which is where FUNC(beginPlanning) started it.
if (_points isEqualTo []) then {
    _route set [ROUTE_HEAD, getPosASL _hull];
    _route set [ROUTE_DIR, getDir _hull];
} else {
    private _last = _points select -1;
    // Heading of the final leg: from whatever precedes the new end — the point
    // before it, or the subject when the route is down to a single point. The
    // negative index is only ever reached with two points in hand.
    private _prior = if (count _points > 1) then {
        _points select -2
    } else {
        getPosASL _hull
    };
    _route set [ROUTE_HEAD, _last];
    _route set [ROUTE_DIR, _prior getDir _last];
};

// The head moved, so an aircraft's altitude readout is stale
if ((_route select ROUTE_KIND) == KIND_AIR) then {
    _route set [ROUTE_ALT, format ["%1 m", round ((ASLToAGL (_route select ROUTE_HEAD)) select 2)]];
};

// The pick that drove this cut is stale the moment the points move
GVAR(hoveredPoint) = [];

true
