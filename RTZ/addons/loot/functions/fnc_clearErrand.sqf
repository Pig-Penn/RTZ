#include "script_component.hpp"
/*
 * Author: Maxim
 * Release a loot errand unit back to its group and drop the errand claim stashed on
 * it. Shared tail of both outcomes - the loot itself (FUNC(lootSquads)'s arrival
 * hook) and the walk timing out or the unit dying on the way. The generic half of
 * the release (force move flag, stance, formation) is EFUNC(common,clearErrand);
 * this only adds the loot claim on top.
 *
 * Extra arguments are ignored, so this can be handed to EFUNC(common,approach)
 * directly as its onFail hook.
 *
 * Arguments:
 * 0: Unit <OBJECT> - objNull is a no-op
 *
 * Return Value:
 * None
 *
 * Example:
 * [_unit] call rtz_loot_fnc_clearErrand
 *
 * Public: No
 */

params ["_unit"];

if (isNull _unit) exitWith {};

_unit setVariable [QGVAR(looting), nil];

[_unit] call EFUNC(common,clearErrand);
