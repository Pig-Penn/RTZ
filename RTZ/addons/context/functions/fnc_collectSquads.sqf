#include "script_component.hpp"
/*
 * rtz_fnc_collectSquads
 *
 * Resolves a Zeus selection (mixed objects / hovered entity / crew) to a unique
 * list of groups. A selected man contributes his own group; a selected vehicle
 * contributes the groups of its crew. Mirror of FUNC(collectVehicles) /
 * FUNC(collectOfficers) but returns groups rather than objects.
 *
 * Parameters:
 *   0: Array — objects from curatorSelected / a ZEN action's selection + hovered
 * Returns: Array of unique non-null groups
 */

params ["_objects"];
private _grps = [];
{
    // Skip non-objects (a hovered group/waypoint can arrive here via a modifier).
    if (_x isEqualType objNull) then {
        private _cands = if (_x isKindOf "CAManBase") then { [_x] } else { crew _x };
        {
            private _g = group _x;
            if (!isNull _g) then { _grps pushBackUnique _g; };
        } forEach _cands;
    };
} forEach _objects;
_grps
