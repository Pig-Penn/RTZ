#include "script_component.hpp"
/*
 * Author: Maxim
 * Builds one context menu child action per weapon the selected aircraft can strike
 * a ground position with, labelled with its display name and how many rounds it has
 * left. The parent action hides itself automatically when no children are returned.
 *
 * The count is informational, not an order size: one strike is one pass, and how
 * much of a pylon that pass spends depends on the weapon's shot cap.
 *
 * Arguments:
 * 0: Context position ASL <ARRAY>
 * 1: Selected objects <ARRAY>
 *
 * Return Value:
 * Child actions <ARRAY>
 *
 * Example:
 * private _children = [_position, _objects] call rtz_airstrike_fnc_strikeActions
 *
 * Public: No
 */

params ["_position", "_objects"];

if (!GVAR(enabled)) exitWith {[]};

private _vehicle = [_objects] call FUNC(strikeAircraft);
if (isNull _vehicle) exitWith {[]};

// Bearing -1 means "come in the way you are already pointing". Task 3 replaces this
// statement with the drag session, which supplies a real bearing.
private _statement = {[_position, _objects, _args, -1] call FUNC(orderStrike)};

([_vehicle] call FUNC(strikeWeapons)) apply {
    _x params ["_weapon", "_turretPath", "_type", "_ammo"];

    private _config = configFile >> "CfgWeapons" >> _weapon;

    [
        _weapon,
        format [LLSTRING(WeaponLabel), getText (_config >> "displayName"), _ammo],
        getText (_config >> "picture"),
        _statement,
        {true},
        [_vehicle, _weapon, _turretPath, _type]
    ]
}
