#include "script_component.hpp"
/*
 * Author: Maxim
 * SERVER: takes one cell's heightmap vertex down to a given fraction of full depth.
 * The only function in the component that touches the world.
 *
 * setTerrainHeight is server-only — both ACE and Zeus Wargame enforce the same, and
 * Wargame remoteExecs to machine 2 specifically to get there. Edited heights ARE
 * carried in the JIP queue, so a client joining later sees the trench; they are NOT
 * carried in savegames, which is what TRENCH_HEIGHTS would have to replay.
 *
 * The height is ABSOLUTE, computed from the pristine value the plan captured, never
 * subtracted from whatever the heightmap currently reads. A cell is sunk ~15 times
 * over its dig and neighbouring cells share vertices, so an incremental subtraction
 * would give a different answer depending on which neighbour ticked last and would be
 * permanently wrong after a single dropped event.
 *
 * Arguments:
 * 0: Trench record <ARRAY>
 * 1: Cell, indexed by the CELL_* macros <ARRAY>
 * 2: How far down to take it, 0..1 of GVAR(depth) <NUMBER>
 *
 * Return Value:
 * None
 *
 * Example:
 * [_record, _cell, 0.5] call rtz_dig_fnc_sinkCell
 *
 * Public: No
 */

params ["_record", "_cell", "_fraction"];

_cell params ["", "_vertex", "_sunk"];

// The two end cells own no interior vertex and deform nothing.
if (_vertex isEqualTo []) exitWith {};

_fraction = 0 max (_fraction min 1);

// Monotonic. Progress arrives from the digger's machine, so an event can be late or
// repeated; without this a stale fraction would RAISE ground that has already been
// dug, which is visible and permanent.
if (_fraction <= _sunk) exitWith {};

_vertex params ["_vx", "_vy", "_original"];

// Captured on the first sink only, not on every tick: this is the list a fill-in
// order would restore from, and it wants one entry per vertex.
if (_sunk <= 0) then {
    (_record select TRENCH_HEIGHTS) pushBack _vertex;
};

// Clamped against the waterline, but never ABOVE the ground that was already here —
// a forced dig below sea level then does nothing rather than raising the seabed.
private _height = (_original - (_fraction * GVAR(depth))) max (MIN_HEIGHT min _original);

// adjustObjects FALSE, as ACE passes true. ACE lifts the objects it is about to place
// with the terrain; there is nothing of ours to lift any more, so what the flag would
// move now is other people's — the digger himself, and anything a curator built beside
// the line. Zeus Wargame passes false for that reason.
setTerrainHeight [[[_vx, _vy, _height]], false];

_cell set [CELL_SUNK, _fraction];
