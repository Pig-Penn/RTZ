#include "script_component.hpp"
/*
 * Author: Maxim
 * SERVER: takes a committed dig order, re-plans it authoritatively, and puts the
 * engineers to work.
 *
 * The plan is made again here rather than trusted from the client. The curator's
 * preview ran the same FUNC(planTrench) as he dragged, but seconds have passed and
 * something may have driven onto the line since — and a client is not the authority
 * on world state in any case.
 *
 * Arguments:
 * 0: Start position ASL <ARRAY>
 * 1: End position ASL <ARRAY>
 * 2: Ignore safety checks <BOOL>
 * 3: Engineers <ARRAY of OBJECT>
 * 4: Ordering curator <OBJECT>
 *
 * Return Value:
 * None
 *
 * Example:
 * [_start, _end, false, _engineers, _curator] call rtz_dig_fnc_startDig
 *
 * Public: No
 */

params ["_start", "_end", "_force", "_engineers", "_curator"];

if (!GVAR(enabled)) exitWith {};

([_start, _end, _force] call FUNC(planTrench)) params ["_valid", "_reason", "_cells", "_scale"];

if (!_valid) exitWith {
    [_curator, _reason] call EFUNC(common,notifyCurator);
};

// Re-checked here, not just at order time: the walk from the curator's client to
// this machine is a round trip, and a digger can die inside it.
_engineers = _engineers select {alive _x && {isNull objectParent _x}};

if (_engineers isEqualTo []) exitWith {
    [_curator, LLSTRING(MsgNoDiggers)] call EFUNC(common,notifyCurator);
};

GVAR(nextId) = GVAR(nextId) + 1;

private _record = [GVAR(nextId), [], [], _curator, count _cells, count _cells, _cells, _scale];

GVAR(trenches) pushBack _record;

// Bounded, per the multi-hour operations this mod is built for. The OLDEST record
// is dropped rather than the newest refused, so digging never stops working — what
// is lost is only the ability to fill that trench back in later. The trench itself
// stays in the world; nothing is deleted here.
while {count GVAR(trenches) > GVAR(maxTrenches)} do {
    GVAR(trenches) deleteAt 0;
};

// Engineers are ordered along the trench and given CONTIGUOUS runs of cells, so
// each one walks to the near end of his own stretch instead of the squad crossing
// over each other to reach interleaved cells.
private _head = (_cells select 0) select CELL_CENTRE;
private _ranked = [];

{
    _ranked pushBack [_x distance2D _head, _forEachIndex];
} forEach _engineers;

_ranked sort true;

private _ordered = _ranked apply {_engineers select (_x select 1)};
private _diggers = count _ordered;
private _total = count _cells;

{
    private _digger = _ordered select (floor (_forEachIndex * _diggers / _total));
    private _centre = _x select CELL_CENTRE;

    [
        QGVAR(digCell),
        [_digger, GVAR(nextId), _forEachIndex, [_centre select 0, _centre select 1, 0], _curator],
        _digger
    ] call CBA_fnc_targetEvent;
} forEach _cells;
