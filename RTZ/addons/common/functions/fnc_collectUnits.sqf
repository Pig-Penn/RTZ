#include "script_component.hpp"
/*
 * Author: Maxim
 * Expands a Zeus selection to a flat, unique list of man-class units: a selected
 * man contributes himself, a selected vehicle contributes its crew. Non-object and
 * non-man entries (a hovered group/waypoint can arrive via a ZEN modifier) are
 * discarded. Shared expansion primitive behind FUNC(collectSquads), rtz_attack's
 * getGroups and rtz_mine's getLayers.
 *
 * Arguments:
 * 0: Selected Objects <ARRAY>
 *
 * Return Value:
 * Unique man-class units <ARRAY>
 *
 * Example:
 * [_objects] call rtz_common_fnc_collectUnits
 *
 * Public: No
 */

params ["_objects"];

private _units = [];
{
    if (_x isEqualType objNull) then {
        private _cands = if (_x isKindOf "CAManBase") then { [_x] } else { crew _x };
        { _units pushBackUnique _x } forEach _cands;
    };
} forEach _objects;

_units
