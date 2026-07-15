#include "script_component.hpp"
/*
 * rtz_fnc_collectMineLayers
 *
 * Resolves a Zeus selection (mixed objects / hovered entity / crew) to the
 * unique list of men who can lay a mine: alive, not a player, not incapacitated,
 * and carrying at least one placeable mine magazine (FUNC(findMineMag)). A
 * selected man contributes himself; a selected vehicle contributes its crew.
 * Mirror of FUNC(collectSquads) but returns individual carriers rather than
 * groups, since a mine is laid by a specific man walking to the spot.
 *
 * Parameters:
 *   0: Array — objects from curatorSelected / a ZEN action's selection + hovered
 * Returns: Array of unique mine-carrying units ([] when none qualify)
 */

params ["_objects"];

private _units = [];

{
    // Skip non-objects (a hovered group/waypoint can arrive here via a modifier).
    if (_x isEqualType objNull) then {
        private _cands = if (_x isKindOf "CAManBase") then { [_x] } else { crew _x };
        {
            if (
                alive _x
                && {!isPlayer _x}
                && {lifeState _x isNotEqualTo "INCAPACITATED"}
                && {([_x] call FUNC(findMineMag)) isNotEqualTo ""}
            ) then {
                _units pushBackUnique _x;
            };
        } forEach _cands;
    };
} forEach _objects;

_units
