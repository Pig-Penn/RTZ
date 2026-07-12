#include "script_component.hpp"
/*
 * Author: Maxim
 * Finds the live enemy nearest to the given position that any of the groups
 * is hostile to. The target does not have to be Zeus editable since it is
 * looked up by position, not from the curator selection.
 *
 * Arguments:
 * 0: Position ASL <ARRAY>
 * 1: Groups <ARRAY>
 *
 * Return Value:
 * Target, objNull if there is none <OBJECT>
 *
 * Example:
 * [_position, _groups] call rtz_attack_fnc_findTarget
 *
 * Public: No
 */

params ["_position", "_groups"];

private _pos = ASLToAGL _position;

// Mounted crews are represented by their vehicle
private _target = objNull;
private _minDistance = 1e10;

{
    private _candidate = _x;
    private _side = side _candidate;

    if (
        alive _candidate
        && {_groups findIf {side _x getFriend _side < HOSTILE_THRESHOLD} != -1}
    ) then {
        private _distance = _candidate distance2D _pos;

        if (_distance < _minDistance) then {
            _minDistance = _distance;
            _target = _candidate;
        };
    };
} forEach (_pos nearEntities [["CAManBase", "LandVehicle", "Air", "Ship"], SEARCH_RADIUS]);

_target
