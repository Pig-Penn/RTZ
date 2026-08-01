#include "script_component.hpp"
/*
 * Author: Maxim
 * Orders the selected unit closest to the context menu position that carries the
 * given mine magazine to move there and plant one mine.
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

if (!GVAR(enabled)) exitWith {};

private _pos = ASLToAGL _position;

// Same resolution FUNC(placeActions) offered the magazine from
private _units = ([_objects] call FUNC(getLayers)) select {_magazine in magazines _x};
if (_units isEqualTo []) exitWith {};

// Nearest carrier walks. Ranked in 2D, matching the top-down camera the curator
// picked the spot from
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

[LLSTRING(MsgPlacing)] call EFUNC(common,showCountMessage);
