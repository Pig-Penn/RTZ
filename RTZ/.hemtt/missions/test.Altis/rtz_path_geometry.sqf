/*
 * Pure geometry regressions. Run in the HEMTT test mission's debug console:
 * rtz_path_fnc_advanceFlightPath call compile preprocessFileLineNumbers "rtz_path_geometry.sqf"
 *
 * Receives the production function as _this; no copied implementation, objects,
 * mission state, network events or scheduled waits are involved.
 */
private _advance = _this;
private _cases = [
    ["stationary at waypoint", [[[0, 0, 0]], 0, [0, 0, 0], [0, 0, 0], 1], 1],
    ["stationary outside radius", [[[2, 0, 0]], 0, [0, 0, 0], [0, 0, 0], 1], 0],
    ["fast overshoot", [[[50, 0, 0]], 0, [0, 0, 0], [100, 0, 0], 2], 1],
    ["distant point behind is unvisited", [[[0, 100, 0]], 0, [0, 0, 0], [100, 0, 0], 2], 0],
    ["next leg of hairpin stays pending", [[[50, 0, 0], [25, 0, 0]], 0, [0, 0, 0], [100, 0, 0], 2], 1],
    ["several forward points in one tick", [[[25, 0, 0], [50, 0, 0], [75, 0, 0]], 0, [0, 0, 0], [100, 0, 0], 2], 3],
    ["vertical overshoot", [[[0, 0, 50]], 0, [0, 0, 0], [0, 0, 100], 2], 1],
    ["same XY wrong altitude", [[[50, 0, 50]], 0, [0, 0, 0], [100, 0, 0], 2], 0],
    ["point behind previous position", [[[-50, 0, 0]], 0, [0, 0, 0], [100, 0, 0], 2], 0],
    ["point beyond current position", [[[150, 0, 0]], 0, [0, 0, 0], [100, 0, 0], 2], 0],
    ["arrival radius tangent", [[[50, 2, 0]], 0, [0, 0, 0], [100, 0, 0], 2], 1],
    ["bounded advances", [[[25, 0, 0], [50, 0, 0], [75, 0, 0]], 0, [0, 0, 0], [100, 0, 0], 2, 2], 2],
    ["resume at nonzero index", [[[0, 100, 0], [50, 0, 0]], 1, [0, 0, 0], [100, 0, 0], 2], 2],
    ["already complete", [[[50, 0, 0]], 1, [0, 0, 0], [100, 0, 0], 2], 1],
    ["empty path", [[], 0, [0, 0, 0], [100, 0, 0], 2], 0],
    ["duplicate points", [[[50, 0, 0], [50, 0, 0]], 0, [0, 0, 0], [100, 0, 0], 2], 2]
];

private _failed = [];
{
    _x params ["_name", "_args", "_expected"];
    private _actual = (_args call _advance) select 0;
    if (_actual isNotEqualTo _expected) then {
        _failed pushBack [_name, _expected, _actual];
    };
} forEach _cases;

// A low-FPS tick may hit its work cap before consuming the entire movement.
// Continue from the returned sweep start, preserving ordering across ticks.
private _points = [[25, 0, 0], [50, 0, 0], [75, 0, 0]];
private _first = [_points, 0, [0, 0, 0], [100, 0, 0], 2, 2] call _advance;
private _second = [_points, _first select 0, _first select 1, [110, 0, 0], 2, 2] call _advance;
if (!(_first select 2) || {(_second select 0) != 3} || {_second select 2}) then {
    _failed pushBack ["continue bounded sweep", _first, _second];
};
_points = [[50, 0, 0], [25, 0, 0]];
_first = [_points, 0, [0, 0, 0], [100, 0, 0], 2, 1] call _advance;
_second = [_points, _first select 0, _first select 1, [110, 0, 0], 2, 1] call _advance;
if ((_second select 0) != 1) then {
    _failed pushBack ["hairpin after bounded sweep", 1, _second select 0];
};

if (_failed isNotEqualTo []) then {
    throw format ["RTZ path geometry failed: %1", _failed];
};
diag_log format ["RTZ path geometry: %1 cases passed", count _cases + 2];
count _cases + 2
