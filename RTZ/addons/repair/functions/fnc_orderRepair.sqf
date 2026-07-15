#include "script_component.hpp"
/*
 * Author: Maxim
 * Orders every selected repair-capable engineer to walk to the damaged vehicle
 * nearest the context menu position and repair it. The order runs where each
 * engineer is local.
 *
 * Arguments:
 * 0: Context Position ASL <ARRAY>
 * 1: Selected Objects <ARRAY>
 *
 * Return Value:
 * None
 *
 * Example:
 * [_position, _objects] call rtz_repair_fnc_orderRepair
 *
 * Public: No
 */

params ["_position", "_objects"];

private _units = _objects call FUNC(getRepairers);
if (_units isEqualTo []) exitWith {};

private _vehicle = [_position] call FUNC(findVehicle);
if (isNull _vehicle) exitWith {};

{
    [QGVAR(repair), [_x, _vehicle], _x] call CBA_fnc_targetEvent;
} forEach _units;
