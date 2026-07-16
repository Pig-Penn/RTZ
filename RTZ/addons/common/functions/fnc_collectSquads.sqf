#include "script_component.hpp"
/*
 * Author: Maxim
 * Resolves a Zeus selection to a unique list of groups: a selected man contributes
 * his own group, a selected vehicle the groups of its crew (via FUNC(collectUnits)).
 * The unfiltered normalizer — callers add their own predicates (alive, player-led,
 * capability). Mirror of FUNC(collectVehicles), which returns vehicles instead.
 *
 * Arguments:
 * 0: Selected Objects <ARRAY>
 *
 * Return Value:
 * Unique non-null groups <ARRAY>
 *
 * Example:
 * [_objects] call rtz_common_fnc_collectSquads
 *
 * Public: No
 */

params ["_objects"];

private _grps = [];
{
    private _g = group _x;
    if (!isNull _g) then { _grps pushBackUnique _g };
} forEach ([_objects] call FUNC(collectUnits));

_grps
