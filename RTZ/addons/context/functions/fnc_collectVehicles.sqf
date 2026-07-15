#include "script_component.hpp"
/*
 * rtz_fnc_collectVehicles
 *
 * Resolves a Zeus selection (mixed objects / crew) to a unique vehicle list.
 * Men resolve to their parent vehicle; non-vehicle objects are discarded.
 *
 * Parameters:
 *   0: Array — objects from curatorSelected or a similar source
 * Returns: Array of unique vehicles
 */
 
params ["_objects"];
private _vehs = [];
{
    // Skip non-objects (a hovered group/waypoint can arrive here via the modifier).
    if (_x isEqualType objNull) then {
        // A selected man resolves to the vehicle he is in; a selected vehicle is itself.
        private _v = if (_x isKindOf "CAManBase") then { objectParent _x } else { _x };
        if (!isNull _v && { _v isKindOf "AllVehicles" } && { !(_v isKindOf "CAManBase") }) then {
            _vehs pushBackUnique _v;
        };
    };
} forEach _objects;
_vehs
