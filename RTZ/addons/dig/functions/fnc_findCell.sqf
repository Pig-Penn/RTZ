#include "script_component.hpp"
/*
 * Author: Maxim
 * SERVER: resolves the id and index a digger reports into the record and cell they
 * name, or [] if they name nothing.
 *
 * A digger's machine is never given the plan — CBA events copy their payload, so a
 * record handed across would be mutated there and the server's own copy would never
 * see it sink — so every report from one arrives as an id and an index and has to be
 * looked up here. Both QGVAR(cellProgress) and QGVAR(cellDone) do that, and writing
 * the lookup twice is the shape this codebase's audits keep finding bugs in.
 *
 * Arguments:
 * 0: Trench id <NUMBER>
 * 1: Cell index <NUMBER>
 *
 * Return Value:
 * 0: Trench record <ARRAY>
 * 1: Cell, indexed by the CELL_* macros <ARRAY>
 * Empty when the trench has aged out of the registry or the index is not one of its
 * cells <ARRAY>
 *
 * Example:
 * private _found = [_trenchId, _cellIndex] call rtz_dig_fnc_findCell;
 *
 * Public: No
 */

params ["_trenchId", "_cellIndex"];

private _index = GVAR(trenches) findIf {(_x select TRENCH_ID) == _trenchId};

// Aged out of the bounded registry while this cell was being dug. The trench stops
// where it got to; there is nothing left to attach the cell to.
if (_index == -1) exitWith {[]};

private _record = GVAR(trenches) select _index;
private _cells = _record select TRENCH_CELLS;

if (_cellIndex < 0 || {_cellIndex >= count _cells}) exitWith {[]};

[_record, _cells select _cellIndex]
