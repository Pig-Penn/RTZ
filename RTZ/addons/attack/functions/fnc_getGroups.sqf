#include "script_component.hpp"
/*
 * Author: Maxim
 * Returns the orderable AI groups of the given objects, expanding vehicles
 * to their crews and skipping player-led groups.
 *
 * Arguments:
 * N: Objects <OBJECT>
 *
 * Return Value:
 * Groups <ARRAY>
 *
 * Example:
 * [_object] call rtz_attack_fnc_getGroups
 *
 * Public: No
 */

private _groups = [];

{
    if (alive _x && {!isPlayer _x} && {!isPlayer leader _x}) then {
        _groups pushBackUnique group _x;
    };
} forEach ([_this] call EFUNC(common,collectUnits));

_groups
