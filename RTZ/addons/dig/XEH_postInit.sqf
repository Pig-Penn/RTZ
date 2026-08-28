#include "script_component.hpp"

// The drawing session's other three exits — commit, right-click, Escape — are all
// handlers on the curator display itself, so none of them fire if the display goes
// away out from under an open session: the curator exits Zeus, is kicked from
// curation, disconnects, or the display closes some other way mid-drag. This is the
// only exit that catches that. FUNC(endAiming) already early-exits when
// GVAR(aiming) isEqualTo [], so calling it on every display close costs nothing when
// no session is open.
["zen_curatorDisplayUnloaded", {call FUNC(endAiming)}] call CBA_fnc_addEventHandler;

// Sent by FUNC(startDig) on the server, targeted at the machine that owns the digger.
[QGVAR(digCell), LINKFUNC(digCell)] call CBA_fnc_addEventHandler;

if (!isServer) exitWith {};

// Sent by FUNC(orderDig) from the ordering curator's client.
[QGVAR(start), LINKFUNC(startDig)] call CBA_fnc_addEventHandler;

// Sent by FUNC(digStep) from wherever the digger is local, once his cell is finished.
// The cell itself is NOT carried in the payload — CBA events copy what they are
// given, so the digger's machine holds no part of the plan and cannot mutate the
// server's copy of it. It reports an id and an index; the plan is looked up here.
[QGVAR(cellDone), {
    params ["_trenchId", "_cellIndex"];

    private _index = GVAR(trenches) findIf {(_x select TRENCH_ID) == _trenchId};

    // Aged out of the bounded registry while this cell was being dug. The trench
    // stops where it got to; there is nothing left to attach the cell to.
    if (_index == -1) exitWith {};

    private _record = GVAR(trenches) select _index;
    private _cells = _record select TRENCH_CELLS;

    if (_cellIndex < 0 || {_cellIndex >= count _cells}) exitWith {};

    [_record, _cells select _cellIndex] call FUNC(buildCell);

    // The digger's NEXT cell goes out only now. His run is walked one cell at a
    // time because EFUNC(common,approach) supersedes any pending order on the same
    // lead — see FUNC(dispatchCell) for what dispatching the whole run at once cost.
    //
    // Contiguous runs, so the next cell is his when DIGGER_INDEX yields the same
    // digger for both; a different index means his stretch ended here and the next
    // cell already has its own digger working toward it.
    private _diggers = count (_record select TRENCH_DIGGERS);
    private _total = count _cells;
    private _next = _cellIndex + 1;

    if (_next >= _total) exitWith {};

    if (DIGGER_INDEX(_next,_diggers,_total) != DIGGER_INDEX(_cellIndex,_diggers,_total)) exitWith {};

    [_record, _next] call FUNC(dispatchCell);
}] call CBA_fnc_addEventHandler;
