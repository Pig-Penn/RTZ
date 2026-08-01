#include "script_component.hpp"
/*
 * Author: Maxim
 * Builds a context menu child action for each distinct mine magazine carried by
 * the selected units. The parent action is hidden automatically when no children
 * are returned.
 *
 * One click lays ONE mine, by the single carrier standing closest to the spot. The
 * count in each label is therefore the squad's carried STOCK, not an order size —
 * it is there so a curator can see how many more he has before running dry.
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

if (!GVAR(enabled)) exitWith {[]};

// Same resolution the order itself uses, so the menu can never offer a magazine
// FUNC(orderPlace) then finds nobody carrying
private _units = [_objects] call FUNC(getLayers);
if (_units isEqualTo []) exitWith {[]};

// Tally each placeable mine magazine across the selected units
private _magazines = createHashMap;
private _muzzles = GVAR(muzzles);

{
    {
        if ((toLowerANSI _x) in _muzzles) then {
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
        format [LLSTRING(MagazineLabel), getText (_config >> "displayName"), _magazines get _x],
        getText (_config >> "picture"),
        _statement,
        {true},
        _x
    ] call zen_context_menu_fnc_createAction;

    [_action, [], 0]
}
