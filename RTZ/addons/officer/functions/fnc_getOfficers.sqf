#include "script_component.hpp"
/*
 * Author: Maxim
 * Returns the unique alive officers among the given objects, expanding
 * vehicles to their crews (see FUNC(isOfficer) for the heuristic).
 *
 * Arguments:
 * N: Objects <OBJECT>
 *
 * Return Value:
 * Officers <ARRAY>
 *
 * Example:
 * [_object] call rtz_officer_fnc_getOfficers
 *
 * Public: No
 */

private _officers = [];

{
    // A hovered group/waypoint can arrive here from the context menu — skip non-objects
    if (_x isEqualType objNull) then {
        private _units = if (_x isKindOf "CAManBase") then {[_x]} else {crew _x};

        {
            if (alive _x && {[_x] call FUNC(isOfficer)}) then {
                _officers pushBackUnique _x;
            };
        } forEach _units;
    };
} forEach _this;

_officers
