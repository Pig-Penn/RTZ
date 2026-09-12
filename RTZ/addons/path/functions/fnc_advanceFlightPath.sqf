#include "script_component.hpp"
/*
 * Author: Maxim
 * Advances through waypoints reached by the hull's movement since the last tick.
 * Tests distance to the swept segment in ASL, preserving waypoint order along
 * that segment. A waypoint behind the hull is not necessarily one it visited.
 *
 * Arguments:
 * 0: Path points, ASL <ARRAY>
 * 1: Next waypoint index <NUMBER>
 * 2: Previous hull position, ASL <ARRAY>
 * 3: Current hull position, ASL <ARRAY>
 * 4: Arrival radius, metres <NUMBER>
 * 5: Maximum advances this tick <NUMBER> (default: MAX_SKIP)
 *
 * Return Value:
 * [Next index, remaining sweep start ASL, exhausted tick budget] <ARRAY>
 * Count of points means complete. Carry the sweep start into the next tick so
 * a budget-limited advance does not forget points already crossed at low FPS.
 *
 * Example:
 * [_points, 0, _last, _current, 15] call rtz_path_fnc_advanceFlightPath
 *
 * Public: No
 */

params ["_points", "_index", "_last", "_current", "_radius", ["_maxSkip", MAX_SKIP]];

private _travel = _current vectorDiff _last;
private _lengthSqr = _travel vectorDotProduct _travel;
private _radiusSqr = _radius * _radius;
private _cursor = 0;
private _skips = 0;
private _along = 0;

while {
    _index < count _points && {_skips < _maxSkip} && {
        private _offset = (_points select _index) vectorDiff _last;
        _along = _cursor;
        if (_lengthSqr > 0) then {
            _along = (((_offset vectorDotProduct _travel) / _lengthSqr) max _cursor) min 1;
        };
        private _miss = _offset vectorDiff (_travel vectorMultiply _along);
        (_miss vectorDotProduct _miss) <= _radiusSqr
    }
} do {
    // Only the unconsumed suffix can reach the NEXT waypoint. Otherwise a fast
    // tick crossing an outbound leg could also consume the same route backwards.
    _cursor = _along;
    _index = _index + 1;
    _skips = _skips + 1;
};

private _limited = _skips >= _maxSkip && {_index < count _points};
private _nextStart = _current;
if (_limited) then {_nextStart = _last vectorAdd (_travel vectorMultiply _cursor)};
[_index, _nextStart, _limited]
