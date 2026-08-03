#include "script_component.hpp"
/*
 * Author: Maxim
 * Orders every selected supply vehicle to service the vehicles parked around it.
 * The target set is resolved here, on the curator's client, and shipped to the
 * server in a single event so the service loop never has to search again — the
 * server re-validates and claims what it is given (FUNC(serviceVehicles)) rather
 * than trusting the list, and recomputes the capabilities itself, so the wire
 * carries nothing but objects.
 *
 * Two supply vehicles parked together see each other's targets, and each service
 * job interpolates from its own snapshot, so letting both take one vehicle makes
 * them overwrite each other's fuel and damage every tick. The de-duplication here
 * is first-claim-wins within THIS order; the guard that survives a second order,
 * or a second curator, is the server-side claim.
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

private _orders  = [];
private _claimed = [];

{
    private _targets = ([_x, [_x] call FUNC(supplyCapabilities)] call FUNC(findTargets)) - _claimed;

    if (_targets isNotEqualTo []) then {
        _claimed append _targets;
        _orders pushBack [_x, _targets];
    };
} forEach ([_objects] call FUNC(getSupplyVehicles));

// The condition passed when the menu was built, but a selection can go stale
// between the build and the click — say so rather than swallowing the order.
if (_orders isEqualTo []) exitWith {
    [LLSTRING(MsgNothingToService)] call EFUNC(common,showCountMessage);
};

// player is the ordering curator (this runs on their client) — threaded through
// so FUNC(endService) can report back to whoever actually gave the order
[QGVAR(resupply), [_orders, player]] call CBA_fnc_serverEvent;

// The count that means something to a curator is how many vehicles are being
// worked on, not how many trucks are doing the working
[LLSTRING(MsgResupplying), count _claimed] call EFUNC(common,showCountMessage);
