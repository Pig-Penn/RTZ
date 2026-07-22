#include "script_component.hpp"
/*
 * Author: Maxim
 * Release a mine-laying errand unit back to its group and wipe the transient state
 * stashed on it: drop the LAMBS force move flag, then restore stance and rejoin
 * formation if the unit is still alive and on foot. Shared tail of both outcomes -
 * the mine being planted (FUNC(placeMine)'s arrival hook) and the walk timing out or
 * the unit dying on the way.
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
 * [_unit] call rtz_mine_fnc_clearErrand
 *
 * Public: No
 */

params ["_unit"];

if (isNull _unit) exitWith {};

_unit setVariable ["lambs_danger_forceMove", nil];

if (alive _unit && {isNull objectParent _unit}) then {
    _unit setUnitPosWeak "AUTO";
    _unit doFollow (leader _unit);
};
