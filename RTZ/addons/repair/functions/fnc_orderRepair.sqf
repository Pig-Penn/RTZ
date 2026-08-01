#include "script_component.hpp"
/*
 * Author: Maxim
 * Context menu statement: orders every selected repair-capable engineer to walk to
 * the damaged vehicle nearest the context menu position and work on it.
 *
 * The walk (doMove, the animation) must run where each engineer is local, so the
 * order is targeted per unit. Each engineer carries a fan SLOT so the group rings
 * the vehicle instead of piling onto one spot, and the ordering curator rides
 * along so an engineer who cannot reach the vehicle can say so.
 *
 * The repair itself is NOT done here — the arriving engineers all join one server
 * side job on the vehicle (FUNC(repairJob)), so several engineers speed the work up
 * instead of racing each other with conflicting damage snapshots.
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

if (!GVAR(enabled)) exitWith {};

private _units = [_objects] call FUNC(getRepairers);
if (_units isEqualTo []) exitWith {};

private _vehicle = [_position] call FUNC(findVehicle);
if (isNull _vehicle) exitWith {};

{
    // player is the ordering curator (this runs on their client) — threaded
    // through so the errand can toast them if the engineer can't reach the spot
    [QGVAR(repair), [_x, _vehicle, _forEachIndex, player], _x] call CBA_fnc_targetEvent;
} forEach _units;

[LLSTRING(MsgRepairing), count _units] call EFUNC(common,showCountMessage);
