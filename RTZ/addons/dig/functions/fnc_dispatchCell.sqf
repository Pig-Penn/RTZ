#include "script_component.hpp"
/*
 * Author: Maxim
 * SERVER: sends ONE cell of a trench to the engineer whose run it falls in.
 *
 * A run is dispatched a cell at a time, never all at once, and that is the whole
 * reason this function exists. EFUNC(common,approach) supersedes any pending order
 * on the same lead — it stamps a fresh errand token and the previous order's
 * onArrive AND onFail hooks are both skipped — so N cells handed to one digger in
 * one frame leave N-1 of them abandoned before he takes a step. The trench came out
 * with one cell built per engineer however long it was drawn, TRENCH_PENDING never
 * reached zero, and the completion toast never fired. Every other caller of approach
 * in the mod (rtz_mine, rtz_loot, rtz_assemble, rtz_repair) holds to one errand per
 * unit per order; this is the one that did not.
 *
 * The digger is derived from the cell index rather than stored per cell, through the
 * DIGGER_INDEX macro the QGVAR(cellDone) handler also tests run continuity with, so
 * the assignment rule lives in exactly one place.
 *
 * Nothing about the PLAN crosses the wire: the digger is told an id, an index and a
 * point to stand on. CBA events copy their payload, so a record handed to another
 * machine would be mutated there and the server's own copy would never see a block
 * appear.
 *
 * Arguments:
 * 0: Trench record <ARRAY>
 * 1: Cell index <NUMBER>
 *
 * Return Value:
 * The cell was dispatched <BOOL>
 *
 * Example:
 * [_record, 0] call rtz_dig_fnc_dispatchCell
 *
 * Public: No
 */

params ["_record", "_cellIndex"];

private _cells = _record select TRENCH_CELLS;

if (_cellIndex < 0 || {_cellIndex >= count _cells}) exitWith {false};

private _diggers = _record select TRENCH_DIGGERS;
private _digger = _diggers select DIGGER_INDEX(_cellIndex,count _diggers,count _cells);

// Died between his last cell finishing and this one going out. His remaining run is
// simply never dug — the same outcome as a digger killed mid-cell, where approach's
// failure hook fires and no QGVAR(cellDone) ever comes back. The trench stays short
// and TRENCH_PENDING never reaches zero, which is the honest report.
if (!alive _digger) exitWith {false};

private _centre = (_cells select _cellIndex) select CELL_CENTRE;

[
    QGVAR(digCell),
    [
        _digger,
        _record select TRENCH_ID,
        _cellIndex,
        [_centre select 0, _centre select 1, 0],
        _record select TRENCH_CURATOR
    ],
    _digger
] call CBA_fnc_targetEvent;

true
