#include "script_component.hpp"
/*
 * Author: Maxim
 * Walks one engineer to one cell and starts him digging. Must run where the
 * engineer is local — EFUNC(common,approach) issues a doMove, which does not
 * survive its unit moving to another machine.
 *
 * Arguments:
 * 0: Engineer <OBJECT>
 * 1: Trench id <NUMBER>
 * 2: Cell index <NUMBER>
 * 3: Cell centre AGL <ARRAY>
 * 4: Ordering curator <OBJECT>
 *
 * Return Value:
 * None
 *
 * Example:
 * [_unit, 3, 0, [1000, 2000, 0], _curator] call rtz_dig_fnc_digCell
 *
 * Public: No
 */

params ["_unit", "_trenchId", "_cellIndex", "_centre", "_curator"];

[
    [_unit], _centre, DIG_DISTANCE, GVAR(digTimeout),
    {
        params ["_unit", "_trenchId", "_cellIndex"];

        // Settle before kneeling: approach resolves within a couple of metres, by
        // which point the digger may still be walking.
        doStop _unit;

        // The errand token is read HERE, not built into the arguments above.
        // approach stamps a NEW token on the unit as it takes him, so a token read
        // before that call is the previous errand's and every guard in FUNC(digStep)
        // would fail closed on the very first tick. rtz_mine's plantMine reads it at
        // the same point for the same reason.
        //
        // Release is NOT hooked to arrival either: FUNC(digStep) holds the digger
        // through the whole dig and clears the errand itself when the cell is done.
        [
            _unit, _trenchId, _cellIndex,
            CBA_missionTime + GVAR(cellDuration),
            [_unit] call EFUNC(common,errandToken)
        ] call FUNC(digStep)
    },
    // Errand expired or the digger died — drop the guard and rejoin formation. The
    // cell is simply never built, and the trench stays short by one.
    // clearErrand ignores the extra _args entries, so it is a hook as-is.
    ELINKFUNC(common,clearErrand),
    [_unit, _trenchId, _cellIndex],
    true,                           // forceMove: hold the digger against the LAMBS danger FSM
    _curator,
    LLSTRING(MsgUnreachable)
] call EFUNC(common,approach);
