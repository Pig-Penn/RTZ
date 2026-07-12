#include "script_component.hpp"
/*
 * Author: Maxim
 * Finds the active mine nearest to the context menu position that a selected
 * explosive specialist's side has detected, and the closest such specialist.
 *
 * Arguments:
 * 0: Context Position ASL <ARRAY>
 * 1: Selected Objects <ARRAY>
 *
 * Return Value:
 * Unit and Mine, empty if there is no valid pair <ARRAY>
 *
 * Example:
 * [_position, _objects] call rtz_mine_fnc_findDisarmTarget
 *
 * Public: No
 */

params ["_position", "_objects"];

private _specialists = _objects select {
    _x isKindOf "CAManBase" && {alive _x} && {isNull objectParent _x} && {_x getUnitTrait "explosiveSpecialist"}
};
if (_specialists isEqualTo []) exitWith {[]};

private _pos = ASLToAGL _position;

// Nearest active mine to the clicked position that a specialist's side has spotted
private _mine = objNull;
private _minDistance = 1e10;

{
    private _candidate = _x;
    private _distance = _candidate distance2D _pos;

    if (
        _distance <= SEARCH_RADIUS && {_distance < _minDistance} && {mineActive _candidate}
        && {_specialists findIf {_candidate mineDetectedBy side group _x} != -1}
    ) then {
        _minDistance = _distance;
        _mine = _candidate;
    };
} forEach allMines;

if (isNull _mine) exitWith {[]};

// Closest specialist whose side has spotted the mine
private _unit = objNull;
_minDistance = 1e10;

{
    if (_mine mineDetectedBy side group _x) then {
        private _distance = _x distance2D _mine;

        if (_distance < _minDistance) then {
            _minDistance = _distance;
            _unit = _x;
        };
    };
} forEach _specialists;

[_unit, _mine]
