#include "script_component.hpp"
/*
 * Author: Maxim
 * SERVER: builds one finished cell — drops its heightmap vertex and creates its
 * blocks. The only function in the component that touches the world.
 *
 * setTerrainHeight is server-only (both ACE and Zeus Wargame enforce this), and
 * createSimpleObject with two arguments is GLOBAL — CBA's own fnc_createNamespace
 * branches on exactly that, taking the bare two-argument form as its global case —
 * so the blocks reach every client, and JIP clients, as ordinary networked objects.
 * The third argument would make them local; LAMBS passes it for throwaway debug
 * arrows, which is what it is for.
 *
 * Arguments:
 * 0: Trench record <ARRAY>
 * 1: Cell, indexed by the CELL_* macros <ARRAY>
 *
 * Return Value:
 * None
 *
 * Example:
 * [_record, _cell] call rtz_dig_fnc_buildCell
 *
 * Public: No
 */

params ["_record", "_cell"];

_cell params ["", "_vertex", "_blocks", "_cut"];

private _scale = _record select TRENCH_SCALE;

// Terrain first, blocks second — the blocks are placed at heights resolved off
// pristine terrain by FUNC(planTrench), so the order only matters for the objects
// already standing here, and there are none: the plan refused the cell otherwise.
//
// adjustObjects FALSE, where ACE passes true. ACE deforms the WHOLE trench before
// placing any block, so it has nothing of its own to disturb. This builds cell by
// cell, and neighbouring cells share vertices — with true, every later cell would
// drag the blocks its finished neighbour had already placed down with it. Zeus
// Wargame's own digging passes false for the same reason.
if (_vertex isNotEqualTo []) then {
    _vertex params ["_vx", "_vy", "_original"];

    (_record select TRENCH_HEIGHTS) pushBack _vertex;

    setTerrainHeight [[[_vx, _vy, _original + LAND_ADJUST]], false];
};

private _created = _record select TRENCH_BLOCKS;

// Cutter before the walls so it is not left sitting on top of them. Sized with the
// blocks: a cutter scaled for a 3.75 m model clears nothing on a 7.5 m cell.
if (_cut) then {
    (_blocks select 0) params ["_floorPos", "", "_floorUp"];

    private _cutter = createSimpleObject [CLUTTER_CUTTER, _floorPos];
    _cutter setVectorDirAndUp [[0, 1, 0], _floorUp];

    if (_scale != 1) then {
        _cutter setObjectScale _scale;
    };

    _created pushBack _cutter;
};

{
    _x params ["_pos", "_dir", "_up"];

    private _block = createSimpleObject [TRENCH_BLOCK, _pos];
    _block setVectorDirAndUp [_dir, _up];

    if (_scale != 1) then {
        _block setObjectScale _scale;
    };

    _created pushBack _block;
} forEach _blocks;

// Pending reaches zero only if every cell was actually dug. A squad wiped out
// halfway leaves a half-built trench and no toast, which is the honest report.
_record set [TRENCH_PENDING, (_record select TRENCH_PENDING) - 1];

if ((_record select TRENCH_PENDING) <= 0) then {
    [_record select TRENCH_CURATOR, LLSTRING(MsgComplete)] call EFUNC(common,notifyCurator);
};
