#include "script_component.hpp"
/*
 * Author: Maxim
 * Resolves a Zeus selection to a unique vehicle list: a selected man resolves to
 * the vehicle he is in, a selected vehicle is itself, everything else is discarded.
 * Mirror of FUNC(collectSquads), which returns groups instead.
 *
 * Arguments:
 * 0: Selected Objects <ARRAY>
 *
 * Return Value:
 * Unique vehicles <ARRAY>
 *
 * Example:
 * [_objects] call rtz_common_fnc_collectVehicles
 *
 * Public: No
 */

params ["_objects"];

private _vehs = [];
{
    // Skip non-objects (a hovered group/waypoint can arrive here via a modifier).
    if (_x isEqualType objNull) then {
        // A selected man resolves to the vehicle he is in; a selected vehicle is itself.
        private _v = if (_x isKindOf "CAManBase") then { objectParent _x } else { _x };
        if (!isNull _v && { _v isKindOf "AllVehicles" } && { !(_v isKindOf "CAManBase") }) then {
            _vehs pushBackUnique _v;
        };
    };
} forEach _objects;

_vehs
