#include "script_component.hpp"
/*
 * Author: Maxim
 * Drops every claim slot on a target that is still held by this supply vehicle.
 * Called by FUNC(serviceTick) when a target is dropped mid-order and by
 * FUNC(endService) on every way a job can end.
 *
 * Only slots held by THIS vehicle are released, so releasing can never take a
 * service away from a job that has since claimed it — the same rule the single
 * exclusive claim followed, applied per slot.
 *
 * The variable is removed outright once its last slot goes free rather than being
 * left as [[], [], []]. FUNC(grantedServices) short-circuits on an empty claim and
 * skips its walk entirely, so this keeps the common case common: a vehicle that has
 * been serviced and released looks exactly like one that never was.
 *
 * Both writes are PUBLIC, matching the claim FUNC(serviceVehicles) takes: curators'
 * clients read the slots through FUNC(grantedServices) to decide what the picker offers.
 *
 * Arguments:
 * 0: Target <OBJECT>
 * 1: Supply Vehicle <OBJECT>
 *
 * Return Value:
 * None
 *
 * Example:
 * [_tank, _truck] call rtz_supply_fnc_releaseClaims
 *
 * Public: No
 */

params ["_target", "_supply"];

// objNull covers the drop path: FUNC(serviceTick) nulls the target when it dies or
// drives off, having already released here, and FUNC(endService) then calls this
// again on every path.
if (isNull _target) exitWith {};

private _claim = _target getVariable [QGVAR(claim), []];
if (_claim isEqualTo []) exitWith {};

private _released = false;

{
    if ((_x param [0, objNull]) isEqualTo _supply) then {
        _claim set [_forEachIndex, []];
        _released = true;
    };
} forEach _claim;

if (!_released) exitWith {};

if (_claim findIf {_x isNotEqualTo []} == -1) exitWith {
    _target setVariable [QGVAR(claim), nil, true];
};

_target setVariable [QGVAR(claim), _claim, true];
