#include "script_component.hpp"
/*
 * Author: Maxim
 * CLIENT: resolve a Zeus selection (objects + hovered entity, pre-merged by the
 * caller) to the downed casualties that are still loadable — i.e. in the "DOWN"
 * state (not yet aboard a vehicle). State comes from the server snapshot cached
 * in GVAR(casualtyStates) (netId -> state) by FUNC(casualtyIndicator).
 *
 * Arguments:
 * 0: Objects from a ZEN action's selection + hovered entity <ARRAY>
 *
 * Return Value:
 * Unique loadable casualty units <ARRAY>
 *
 * Example:
 * [_objects] call rtz_casualty_fnc_collectCasualties
 *
 * Public: No
 */

params ["_objects"];
private _out = [];
{
    // Skip non-objects (a hovered group/waypoint can arrive here via a modifier).
    if (_x isEqualType objNull && {_x isKindOf "CAManBase"}) then {
        if ((GVAR(casualtyStates) getOrDefault [netId _x, ""]) == "DOWN") then {
            _out pushBackUnique _x;
        };
    };
} forEach _objects;
_out
