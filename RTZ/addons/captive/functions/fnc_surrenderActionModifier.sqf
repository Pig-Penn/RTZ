#include "script_component.hpp"
/*
 * Author: Maxim
 * CfgContext modifierFunction for the surrender toggle (see CfgContext.hpp).
 * Mutates the action's displayName, icon and iconColor to reflect whether the
 * first selected/hovered unit is currently surrendered:
 *   fighting            -> white "Surrender"
 *   surrendered, locked -> grey  "Stand Down — Xs" (inside the lock window)
 *   surrendered, free   -> green "Stand Down"
 * (Captured prisoners never reach here — FUNC(collectSurrenderUnits) excludes them.)
 *
 * Arguments:
 * 0: Action <ARRAY>
 * 1: Objects from a ZEN action's selection + hovered entity <ARRAY>
 *
 * Return Value:
 * None
 *
 * Example:
 * [_action, _objects] call rtz_captive_fnc_surrenderActionModifier
 *
 * Public: No
 */

params ["_action", "_objects"];

private _units = [_objects] call FUNC(collectSurrenderUnits);
if (_units isEqualTo []) exitWith {};

private _unit = _units select 0;
if (_unit getVariable [QGVAR(surrendered), false]) then {
    private _remaining = ceil (GVAR(standDownLockTime)
        - (CBA_missionTime - (_unit getVariable [QGVAR(surrenderTime), CBA_missionTime])));
    if (_remaining > 0) then {
        _action set [ACTION_INDEX_DISPLAYNAME, format [LLSTRING(ActionStandDownLocked), _remaining]];
        _action set [ACTION_INDEX_ICON, ICON_STANDDOWN];
        _action set [ACTION_INDEX_ICONCOLOR, COLOR_LOCKED];
    } else {
        _action set [ACTION_INDEX_DISPLAYNAME, LLSTRING(ActionStandDown)];
        _action set [ACTION_INDEX_ICON, ICON_STANDDOWN];
        _action set [ACTION_INDEX_ICONCOLOR, COLOR_STANDDOWN];
    };
} else {
    _action set [ACTION_INDEX_DISPLAYNAME, LLSTRING(ActionSurrender)];
    _action set [ACTION_INDEX_ICON, ICON_SURRENDER];
    _action set [ACTION_INDEX_ICONCOLOR, COLOR_SURRENDER];
};
