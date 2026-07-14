#include "script_component.hpp"
/*
 * Author: Maxim
 * Toggles the editing-area state of the officers among the given objects.
 * Reads the current state from the FIRST officer and applies the inverse to
 * all of them, so a mixed selection follows the label the curator just
 * clicked (see FUNC(modifyAction)).
 *
 * Arguments:
 * N: Objects <OBJECT>
 *
 * Return Value:
 * None
 *
 * Example:
 * [_object] call rtz_officer_fnc_toggleArea
 *
 * Public: No
 */

private _officers = _this call FUNC(getOfficers);
if (_officers isEqualTo []) exitWith {};

private _enable = !(netId (_officers select 0) in GVAR(areas));
private _applied = 0;

{
    if ([_x, _enable] call FUNC(setArea)) then {
        _applied = _applied + 1;
    };
} forEach _officers;

if (_enable) then {
    if (_applied > 0) then {
        [LSTRING(MsgAreaAdded), round GVAR(areaRadius)] call zen_common_fnc_showMessage;
    } else {
        private _cooldown = [_officers select 0] call FUNC(isOnCooldown);

        if (_cooldown > 0) then {
            [LSTRING(MsgAreaCooldown), ceil _cooldown] call zen_common_fnc_showMessage;
        } else {
            [LSTRING(MsgAreaBlocked)] call zen_common_fnc_showMessage;
        };
    };
} else {
    [LSTRING(MsgAreaRemoved)] call zen_common_fnc_showMessage;
};
