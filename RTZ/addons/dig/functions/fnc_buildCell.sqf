#include "script_component.hpp"
/*
 * Author: Maxim
 * SERVER: finishes one cell — takes its vertex to full depth, cuts the grass out of
 * the hole, and counts the cell off against the trench.
 *
 * The dig itself happens in FUNC(sinkCell), called ~15 times over the cell's life by
 * the progress the digger reports. This is only the last of those calls plus the
 * bookkeeping, so the terrain a curator watched sink does not jump at the end.
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

[_record, _cell, 1] call FUNC(sinkCell);

_cell params ["", "_vertex"];

// Grass, not geometry. Nothing is modelled here, so a shallow dip left full of clutter
// reads as a fold in the ground rather than as a trench — the cutter is what makes it
// legible. Only where there is a vertex: the end cells deform nothing, so they have no
// hole to clear.
//
// Created with the bare two-argument createSimpleObject, which is GLOBAL (CBA's own
// fnc_createNamespace branches on exactly that, and the third argument is what makes
// one local), so it reaches every client and JIP like any networked object.
if (_vertex isNotEqualTo []) then {
    _vertex params ["_vx", "_vy"];

    private _at = [_vx, _vy, getTerrainHeightASL [_vx, _vy]];
    private _cutter = createSimpleObject [CLUTTER_CUTTER, _at];

    // Read AFTER the sink above, so it lies in the finished dip rather than on the
    // slope that was here before the cell was dug.
    _cutter setVectorUp (surfaceNormal _at);

    // Paired with its creation, here, rather than parked in the record: there is
    // nothing else left that outlives a dig, and a cutter whose deletion depended on
    // some later step would leak for the rest of the mission if that step never ran.
    [{deleteVehicle (_this select 0)}, [_cutter], CUTTER_LIFETIME] call CBA_fnc_waitAndExecute;
};

// Pending reaches zero only if every cell was actually dug. A squad wiped out
// halfway leaves a half-built trench and no toast, which is the honest report.
_record set [TRENCH_PENDING, (_record select TRENCH_PENDING) - 1];

if ((_record select TRENCH_PENDING) <= 0) then {
    [_record select TRENCH_CURATOR, LLSTRING(MsgComplete)] call EFUNC(common,notifyCurator);
};
