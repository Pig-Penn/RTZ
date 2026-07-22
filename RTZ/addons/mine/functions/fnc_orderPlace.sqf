#include "script_component.hpp"
/*
 * Author: Maxim
 * Orders the selected unit closest to the context menu position that
 * carries the given mine magazine to move there and plant the mine.
 *
 * Arguments:
 * 0: Context Position ASL <ARRAY>
 * 1: Selected Objects <ARRAY>
 * 2: Magazine <STRING>
 *
 * Return Value:
 * None
 *
 * Example:
 * [_position, _objects, "ATMine_Range_Mag"] call rtz_mine_fnc_orderPlace
 *
 * Public: No
 */

params ["_position", "_objects", "_magazine"];

private _pos = ASLToAGL _position;
private _units = _objects select {
    _x isKindOf "CAManBase" && {alive _x} && {isNull objectParent _x} && {_magazine in magazines _x}
};
if (_units isEqualTo []) exitWith {};

private _unit = objNull;
private _minDistance = 1e10;

{
    private _distance = _x distance2D _pos;

    if (_distance < _minDistance) then {
        _minDistance = _distance;
        _unit = _x;
    };
} forEach _units;

// player is the ordering curator (this runs on their client) — threaded through so
// FUNC(placeMine) can toast them if the layer can't reach the spot.
[QGVAR(place), [_unit, _pos, _magazine, player], _unit] call CBA_fnc_targetEvent;
