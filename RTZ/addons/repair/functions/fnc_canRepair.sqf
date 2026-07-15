#include "script_component.hpp"
/*
 * Author: Maxim
 * Whether a repair order is possible: at least one selected unit can repair
 * and there is a damaged vehicle near the context menu position. Drives the
 * visibility of the context menu action.
 *
 * Arguments:
 * 0: Context Position ASL <ARRAY>
 * 1: Selected Objects <ARRAY>
 *
 * Return Value:
 * Order Possible <BOOL>
 *
 * Example:
 * [_position, _objects] call rtz_repair_fnc_canRepair
 *
 * Public: No
 */

params ["_position", "_objects"];

if ((_objects call FUNC(getRepairers)) isEqualTo []) exitWith {false};

!isNull ([_position] call FUNC(findVehicle))
