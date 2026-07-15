#include "script_component.hpp"
/*
 * Author: Maxim
 * Builds a context menu child action for each distinct mine magazine carried by the selected units.
 * The parent action is hidden automatically when no children are returned.
 *
 * Arguments:
 * 0: Context Position ASL <ARRAY>
 * 1: Selected Objects <ARRAY>
 *
 * Return Value:
 * Child Actions <ARRAY>
 *
 * Example:
 * [_position, _objects] call rtz_mine_fnc_placeActions
 *
 * Public: No
 */

params ["_position", "_objects"];

private _units = _objects select {_x isKindOf "CAManBase" && {alive _x} && {isNull objectParent _x}};
if (_units isEqualTo []) exitWith {[]};

// Tally each placeable mine magazine across the selected units
private _magazines = createHashMap;

{
    {
        if ((toLowerANSI _x) in GVAR(muzzles)) then {
            _magazines set [_x, (_magazines getOrDefault [_x, 0]) + 1];
        };
    } forEach magazines _x;
} forEach _units;

private _statement = {[_position, _objects, _args] call FUNC(orderPlace)};

private _names = keys _magazines;
_names sort true;

_names apply {
    private _config = configFile >> "CfgMagazines" >> _x;

    private _action = [
        _x,
        format ["%1 (%2)", getText (_config >> "displayName"), _magazines get _x],
        getText (_config >> "picture"),
        _statement,
        {true},
        _x
    ] call zen_context_menu_fnc_createAction;

    [_action, [], 0]
}
