#include "script_component.hpp"
/*
 * Author: Maxim
 * Lets Zeus pick a live enemy by clicking in the world or on the map, then
 * orders the selected AI groups to destroy it, replacing their current
 * waypoints. The cursor shows whether a valid target is under it.
 *
 * Arguments:
 * N: Selected Objects <OBJECT>
 *
 * Return Value:
 * None
 *
 * Example:
 * [_object] call rtz_attack_fnc_orderDestroy
 *
 * Public: No
 */

private _groups = _this call FUNC(getGroups);

if (_groups isEqualTo []) exitWith {};

private _modifierFunction = {
    params ["", "_position", "_groups", "_visuals"];

    if (isNull ([_position, _groups] call FUNC(findTarget))) then {
        _visuals set [0, LSTRING(NoTarget)];
        _visuals set [3, COLOR_INVALID];
    } else {
        _visuals set [0, LSTRING(ActionDestroy)];
        _visuals set [3, COLOR_TARGET];
    };
};

[_groups apply {leader _x}, {
    params ["_confirmed", "", "_position", "_groups"];

    if (!_confirmed) exitWith {};

    private _target = [_position, _groups] call FUNC(findTarget);

    if (isNull _target) exitWith {
        [LSTRING(NoTarget)] call zen_common_fnc_showMessage;
    };

    private _elements = [["ICON", [_target, ICON_ATTACK, COLOR_TARGET]]];

    {
        [QGVAR(destroy), [_x, _target], leader _x] call CBA_fnc_targetEvent;

        _elements pushBack ["LINE", [leader _x, _target, COLOR_TARGET]];
    } forEach _groups;

    [_elements, HINT_DURATION, _target] call zen_common_fnc_drawHint;
}, _groups, LSTRING(ActionDestroy), nil, nil, nil, _modifierFunction] call zen_common_fnc_selectPosition;
