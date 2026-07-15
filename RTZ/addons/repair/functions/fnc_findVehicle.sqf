#include "script_component.hpp"
/*
 * Author: Maxim
 * Finds the damaged vehicle nearest to the context menu position. The vehicle
 * is looked up by position, not from the curator selection, so it does not
 * have to be Zeus editable. Destroyed and intact vehicles are ignored.
 *
 * Arguments:
 * 0: Context Position ASL <ARRAY>
 *
 * Return Value:
 * Vehicle, objNull if there is none <OBJECT>
 *
 * Example:
 * [_position] call rtz_repair_fnc_findVehicle
 *
 * Public: No
 */

params ["_position"];

private _pos = ASLToAGL _position;

private _vehicle = objNull;
private _minDistance = 1e10;

{
    if (alive _x && {damage _x > REPAIR_THRESHOLD}) then {
        private _distance = _x distance2D _pos;

        if (_distance < _minDistance) then {
            _minDistance = _distance;
            _vehicle = _x;
        };
    };
} forEach (_pos nearEntities [["LandVehicle", "Air", "Ship", "StaticWeapon"], SEARCH_RADIUS]);

_vehicle
