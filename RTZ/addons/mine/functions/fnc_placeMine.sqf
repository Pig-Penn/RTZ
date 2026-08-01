#include "script_component.hpp"
/*
 * Author: Maxim
 * Moves the unit to the given position and plants the mine on arrival.
 * Must be executed where the unit is local.
 *
 * Arguments:
 * 0: Unit <OBJECT>
 * 1: Position AGL <ARRAY>
 * 2: Magazine <STRING>
 * 3: Curator <OBJECT> — toast target if the layer can't reach the spot (default objNull)
 *
 * Return Value:
 * None
 *
 * Example:
 * [_unit, _pos, "ATMine_Range_Mag"] call rtz_mine_fnc_placeMine
 *
 * Public: No
 */

params ["_unit", "_pos", "_magazine", ["_curator", objNull]];

[
    [_unit], _pos, PLACE_DISTANCE, GVAR(placeTimeout),
    {
        params ["_unit", "_magazine"];

        // Release only once the plant has actually resolved — FUNC(plantMine)
        // holds the layer through the PutDown animation, and rejoining formation
        // before that would walk him off mid-kneel and drop the mine short
        [_unit, _magazine, ELINKFUNC(common,clearErrand)] call FUNC(plantMine);
    },
    // Errand expired or the layer died — drop the guard/pose and rejoin formation
    // (skipped when a newer order superseded this one; approach skips onFail then).
    // clearErrand ignores the extra _args entries, so it is a hook as-is.
    ELINKFUNC(common,clearErrand),
    [_unit, _magazine],
    true,                           // forceMove: hold the layer against the LAMBS danger FSM mid-walk
    _curator,
    LLSTRING(PlaceUnreachable)
] call EFUNC(common,approach);
