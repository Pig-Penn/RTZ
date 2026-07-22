#include "script_component.hpp"
/*
 * Author: Maxim
 * Returns the vehicles parked around a supply vehicle that still need something
 * it can give. The lookup is by position rather than from the curator selection,
 * so the serviced vehicles do not have to be Zeus editable.
 *
 * The capabilities are passed in rather than looked up again, and _firstOnly
 * stops at the first hit - the context menu condition only needs to know whether
 * there is any work at all.
 *
 * Arguments:
 * 0: Supply Vehicle <OBJECT>
 * 1: Capabilities, as returned by FUNC(supplyCapabilities) <ARRAY>
 * 2: Stop At The First Match <BOOL> (default: false)
 *
 * Return Value:
 * Serviceable Vehicles <ARRAY>
 *
 * Example:
 * [_truck, [true, true, false]] call rtz_supply_fnc_findTargets
 *
 * Public: No
 */

params ["_supply", "_capabilities", ["_firstOnly", false]];

_capabilities params ["_canRepair", "_canRefuel", "_canRearm"];

private _nearby = _supply nearEntities [SERVICE_TYPES, GVAR(serviceRadius)];

// Ordered cheapest test first: the ammo check walks the turret magazines, so it
// only runs for vehicles that are already fully repaired and fuelled
private _serviceable = {
    _x != _supply && {alive _x}
    && {
        (_canRepair && {damage _x > REPAIR_THRESHOLD})
        || {_canRefuel && {fuel _x < FUEL_THRESHOLD}}
        || {_canRearm && {[_x] call FUNC(needsAmmo)}}
    }
};

if (_firstOnly) exitWith {
    private _index = _nearby findIf _serviceable;

    if (_index < 0) then {[]} else {[_nearby select _index]}
};

_nearby select _serviceable
