#include "script_component.hpp"
/*
 * Author: Maxim
 * Orders every selected supply vehicle to service the vehicles parked around it.
 * The target set is resolved here, on the curator's client, and shipped to the
 * server in a single event so the service loop never has to search again.
 *
 * Arguments:
 * 0: Selected Objects <ARRAY>
 *
 * Return Value:
 * None
 *
 * Example:
 * [_objects] call rtz_supply_fnc_orderResupply
 *
 * Public: No
 */

params ["_objects"];

if (!GVAR(enabled)) exitWith {};

private _orders = [];

// Two supply vehicles parked together see each other's targets. Each service
// loop interpolates from its own snapshot, so letting both take the same vehicle
// makes them overwrite each other's fuel and damage every tick - first claim wins
private _claimed = [];

{
    private _capabilities = [_x] call FUNC(supplyCapabilities);
    private _targets = ([_x, _capabilities] call FUNC(findTargets)) - _claimed;

    if (_targets isNotEqualTo []) then {
        _claimed append _targets;
        _orders pushBack [_x, _capabilities, _targets];
    };
} forEach ([_objects] call FUNC(getSupplyVehicles));

if (_orders isEqualTo []) exitWith {};

[QGVAR(resupply), _orders] call CBA_fnc_serverEvent;
