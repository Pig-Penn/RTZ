#include "script_component.hpp"
/*
 * Author: Maxim
 * Names what a set of supply vehicles collectively offers: the single service when
 * they all offer only that one, and the generic Resupply pair otherwise.
 *
 * Two callers, which is the reason this exists as a function rather than sitting
 * inline where it started. FUNC(resupplyActionModifier) uses it to relabel the ZEN
 * context entry — selecting only a fuel truck reads "Refuel", with ZEN's own refuel
 * icon — and FUNC(orderResupply) uses the same key as the picker's valid-state
 * cursor text, so the cursor names the exact action the menu entry promised.
 *
 * A mixed selection (a fuel truck alongside an ammo truck, or one vehicle carrying
 * more than one supply) falls back to Resupply, since no single label would
 * describe the order.
 *
 * Returns the stringtable KEY, not the localised text. FUNC(resupplyActionModifier)
 * localises it for the menu; zen_common_fnc_selectPosition localises it itself
 * (it tests isLocalized on the cursor text every frame), so the picker hands the
 * key straight through.
 *
 * Arguments:
 * 0: Supply Vehicles <ARRAY> — already filtered by FUNC(getSupplyVehicles)
 *
 * Return Value:
 * 0: Label Key <STRING>
 * 1: Icon <STRING>
 *
 * Example:
 * [_supplies] call rtz_supply_fnc_serviceLabel
 *
 * Public: No
 */

params ["_supplies"];

private _repair = false;
private _fuel   = false;
private _ammo   = false;

{
    ([_x] call FUNC(supplyCapabilities)) params ["_r", "_f", "_a"];

    _repair = _repair || _r;
    _fuel   = _fuel   || _f;
    _ammo   = _ammo   || _a;
} forEach _supplies;

// Only name a single service when the set points at exactly one of the three
private _serviceCount = 0;
if (_repair) then { _serviceCount = _serviceCount + 1 };
if (_fuel)   then { _serviceCount = _serviceCount + 1 };
if (_ammo)   then { _serviceCount = _serviceCount + 1 };

if (_serviceCount != 1) exitWith { [LSTRING(ActionResupply), ICON_RESUPPLY] };

if (_repair) exitWith { [LSTRING(ActionRepair), ICON_REPAIR] };
if (_fuel)   exitWith { [LSTRING(ActionRefuel), ICON_REFUEL] };

[LSTRING(ActionRearm), ICON_REARM]
