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
 * Ported from ace_trenches_fnc_blockTrench_place (PabstMirror), split into a
 * planner and a builder — ACE validates and constructs in one pass, which is what
 * forces its own Zeus module to call it with a `_dryRun` flag that returns a
 * different shape. Here the plan IS the shape, and FUNC(buildCell) consumes it.
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
 * 3: Block scale to apply to every created object <NUMBER>
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
    [false, LLSTRING(ReasonWorld), [], 0]
};

private _blockScale = _cellSize / MODEL_SIZE;
private _xOffset = TRENCH_WIDTH + _blockScale * MODEL_X;
private _zOffset = BLOCK_ADJUST - (_blockScale - 1) * MODEL_Z;
private _testRadius = _blockScale * MODEL_SIZE;

// Snap both ends onto heightmap vertices. Everything downstream is expressed in
// whole cells from here on, so this is the only place rounding happens.
private _start2D = (_startASL select [0, 2]) apply {_cellSize * round (_x / _cellSize)};
private _end2D = (_endASL select [0, 2]) apply {_cellSize * round (_x / _cellSize)};

_start2D params ["_ax", "_ay"];
_end2D params ["_bx", "_by"];

// findIf, not a forEach with exitWith: this is a pure existence test and findIf
// short-circuits natively (docs/Knowledge Base/Gotchas.md section 2).
if ([_ax, _ay, _bx, _by] findIf {_x < _cellSize || {_x > (worldSize - _cellSize)}} != -1) exitWith {
    [false, LLSTRING(ReasonBounds), [], 0]
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
    [false, LLSTRING(ReasonShort), [], 0]
};

private _cells = [];
private _reason = "";

// Inclusive: _length cells span the gap, and the extra one closes the far end.
for "_i" from 0 to _length do {
    private _centre = [];
    private _left = [];
    private _right = [];
    private _direction = [];

    if (_east) then {
        _centre = _origin2D vectorAdd [(_i + 0.5) * _cellSize, 0];
        _left = _centre vectorAdd [0, _xOffset];
        _right = _centre vectorAdd [0, -_xOffset];
        _direction = [0, -1, 0];
    } else {
        _centre = _origin2D vectorAdd [0, (_i + 0.5) * _cellSize];
        _left = _centre vectorAdd [_xOffset, 0];
        _right = _centre vectorAdd [-_xOffset, 0];
        _direction = [-1, 0, 0];
    };

    // Existence test first, so the clear case costs one pass and only a genuine
    // refusal pays for the second call that names the reason.
    private _bad = [_centre, _left, _right] findIf {
        ([_x, _testRadius, _force] call FUNC(cellObstruction)) isNotEqualTo ""
    };

    if (_bad != -1) then {
        _reason = [[_centre, _left, _right] select _bad, _testRadius, _force] call FUNC(cellObstruction);
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
        // The ORIGINAL height travels with the plan: FUNC(buildCell) subtracts from
        // this rather than from whatever the heightmap says when it runs, and the
        // same figure is what a fill-in order would restore.
        _vertex = [_at select 0, _at select 1, getTerrainHeight _at];
    };

    // The floor block sits TRENCH_DEPTH below the walls; all three are sunk by
    // _zOffset, which compensates for the block having been scaled up to span a cell.
    // Resolved to 3D first, then handed to surfaceNormal, which wants a real
    // position rather than the bare [x,y] the cell walk works in.
    private _floorASL = _centre + [(getTerrainHeightASL _centre) + _zOffset + TRENCH_DEPTH];
    private _leftASL = _left + [(getTerrainHeightASL _left) + _zOffset];
    private _rightASL = _right + [(getTerrainHeightASL _right) + _zOffset];

    private _blocks = [
        [_floorASL, _direction, surfaceNormal _floorASL],
        [_leftASL, _direction, surfaceNormal _leftASL],
        [_rightASL, _direction vectorMultiply -1, surfaceNormal _rightASL]
    ];

    _cells pushBack [_centre, _vertex, _blocks, _vertex isNotEqualTo []];
};

if (_reason isNotEqualTo "") exitWith {
    [false, _reason, [], 0]
};

[true, "", _cells, _blockScale]
