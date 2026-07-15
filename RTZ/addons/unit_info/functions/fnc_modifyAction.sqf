#include "script_component.hpp"
/*
 * Author: Maxim
 * Updates the context menu action's name based on the tracked state of the given objects.
 *
 * Arguments:
 * 0: Action <ARRAY>
 * 1: Objects <ARRAY>
 *
 * Return Value:
 * None
 *
 * Example:
 * [_action, _objects] call rtz_unit_info_fnc_modifyAction
 *
 * Public: No
 */

params ["_action", "_objects"];

private _units = _objects call FUNC(getUnits);
private _allTracked = _units isNotEqualTo []
    && {_units findIf {!(_x getVariable [QGVAR(tracked), false])} == -1};

_action set [1, [LLSTRING(ActionShow), LLSTRING(ActionHide)] select _allTracked];
