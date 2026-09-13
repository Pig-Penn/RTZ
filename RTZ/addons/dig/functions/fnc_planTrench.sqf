#include "script_component.hpp"
/*
 * Author: Maxim
 * PURE. Turns two world points into the list of grid cells a trench between them
 * would occupy, or the reason it cannot be dug there.
 *
 * The single source of truth for trench geometry, and deliberately side-effect
 * free so it can be called from two places that must never disagree: the curator's
 * preview runs it every PLAN_INTERVAL while he drags, and the server runs it again
 * on commit. A preview that validated by different rules than the builder would
 * promise trenches the server then refuses.
 *
 * Validation is ported from ace_trenches_fnc_blockTrench_place (PabstMirror), split
 * off into a planner — ACE validates and constructs in one pass, which is what forces
 * its own Zeus module to call it with a `_dryRun` flag that returns a different shape.
 * Here the plan IS the shape, and FUNC(sinkCell) consumes it.
 *
 * The trench is axis-aligned, snapped to the heightmap grid, because
 * setTerrainHeight moves vertices and nothing finer exists. A diagonal drag is
 * resolved to whichever axis it lies closest to.
 *
 * Arguments:
 * 0: Start position ASL <ARRAY>
 * 1: End position ASL <ARRAY>
 * 2: Ignore safety checks <BOOL> (default false)
 *
 * Return Value:
 * 0: Diggable <BOOL>
 * 1: Reason when not, "" when it is <STRING>
 * 2: Cells, indexed by the CELL_* macros <ARRAY>
 *
 * Example:
 * ([_start, _end] call rtz_dig_fnc_planTrench) params ["_valid", "_reason", "_cells"];
 *
 * Public: No
 */

params ["_startASL", "_endASL", ["_force", false]];

getTerrainInfo params ["", "", "_cellSize"];

// A map whose heightmap is coarser than the trench is long cannot express one.
// ACE refuses the same range and names Malden (12.5 m) as a real example, so this
// is a legitimate "not on this terrain", not a defensive impossibility.
if (_cellSize < CELL_MIN || {_cellSize > CELL_MAX}) exitWith {
    [false, LLSTRING(ReasonWorld), []]
};

// One cell. Dropping a vertex pulls the ground down in a cone reaching about that far,
// so this is the footprint the dig actually disturbs. It was previously derived from
// the trench block's footprint and its scale, which multiplied out to the same number.
private _testRadius = _cellSize;

// Snap both ends onto heightmap vertices. Everything downstream is expressed in
// whole cells from here on, so this is the only place rounding happens.
private _start2D = (_startASL select [0, 2]) apply {_cellSize * round (_x / _cellSize)};
private _end2D = (_endASL select [0, 2]) apply {_cellSize * round (_x / _cellSize)};

_start2D params ["_ax", "_ay"];
_end2D params ["_bx", "_by"];

// findIf, not a forEach with exitWith: this is a pure existence test and findIf
// short-circuits natively (docs/Knowledge Base/Gotchas.md section 2).
if ([_ax, _ay, _bx, _by] findIf {_x < _cellSize || {_x > (worldSize - _cellSize)}} != -1) exitWith {
    [false, LLSTRING(ReasonBounds), []]
};

// Resolve the drag to an axis, then walk from the LOWER end so the cell order is
// always the same regardless of which way the curator dragged.
private _east = (abs (_ax - _bx)) >= (abs (_ay - _by));
private _origin2D = [];
private _length = 0;

// Rounded because it is a LOOP BOUND. Both ends were snapped to multiples of
// _cellSize above, so the quotient is a whole number in exact arithmetic — but it is
// reached by dividing two floats, and a result of 4.999999 would silently build a
// trench one cell shorter than the one the curator was shown.
if (_east) then {
    _origin2D = [_end2D, _start2D] select (_ax < _bx);
    _length = round ((abs (_ax - _bx)) / _cellSize);
} else {
    _origin2D = [_end2D, _start2D] select (_ay < _by);
    _length = round ((abs (_ay - _by)) / _cellSize);
};

if (_length < MIN_CELLS) exitWith {
    [false, LLSTRING(ReasonShort), []]
};

private _cells = [];
private _reason = "";

// Inclusive: _length cells span the gap, and the extra one closes the far end.
for "_i" from 0 to _length do {
    private _centre = if (_east) then {
        _origin2D vectorAdd [(_i + 0.5) * _cellSize, 0]
    } else {
        _origin2D vectorAdd [0, (_i + 0.5) * _cellSize]
    };

    // ONE probe, at the centre. There used to be three — centre plus a point out at
    // _xOffset either side — because the side WALL BLOCKS stood there and had to land
    // on clear ground. Nothing stands out there now, and a disc of one cell about the
    // centre already covers the inner half of both vertices this cell is between plus
    // the ground the digger kneels on, which is everything the dig disturbs. The
    // flanking probes would veto ground the trench no longer reaches.
    _reason = [_centre, _testRadius, _force] call FUNC(cellObstruction);

    if (_reason isNotEqualTo "") then {
        // break, not exitWith — inside a loop body exitWith is continue, and this
        // loop ASSIGNS, so it would silently become a last-wins reducer over every
        // remaining cell (docs/Knowledge Base/Gotchas.md section 2).
        break;
    };

    // Vertices sit at _i * cellSize, cell centres at (_i + 0.5) * cellSize, so vertex
    // _i is on the boundary between cells _i-1 and _i. The end cells own none.
    private _vertex = [];

    if (_i > 0 && {_i < _length}) then {
        private _at = if (_east) then {
            _origin2D vectorAdd [_i * _cellSize, 0]
        } else {
            _origin2D vectorAdd [0, _i * _cellSize]
        };
        // The ORIGINAL height travels with the plan: every sink is computed as an
        // absolute height from THIS figure rather than from whatever the heightmap
        // says at the time, and the same figure is what a fill-in order would restore.
        _vertex = [_at select 0, _at select 1, getTerrainHeight _at];
    };

    _cells pushBack [_centre, _vertex, 0];
};

if (_reason isNotEqualTo "") exitWith {
    [false, _reason, []]
};

[true, "", _cells]
