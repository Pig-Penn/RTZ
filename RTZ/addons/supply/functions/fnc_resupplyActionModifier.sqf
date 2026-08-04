#include "script_component.hpp"
/*
 * Author: Maxim
 * CfgContext modifierFunction for the resupply order (see CfgContext.hpp).
 * Mutates the action's displayName and icon to name the single service being
 * offered when every selected supply vehicle carries the same one — e.g.
 * selecting only a fuel truck relabels the entry "Refuel" with the refuel
 * icon. A mixed selection (a fuel truck alongside an ammo truck, or a single
 * vehicle that carries more than one supply) falls back to the generic
 * "Resupply" truck icon set in CfgContext.hpp, since no single label would
 * describe the order.
 *
 * Arguments:
 * 0: The action array (mutated in place) <ARRAY>
 * 1: Selected Objects <ARRAY>
 *
 * Return Value:
 * None
 *
 * Example:
 * [_action, _objects] call rtz_supply_fnc_resupplyActionModifier
 *
 * Public: No
 */

params ["_action", "_objects"];

private _repair = false;
private _fuel   = false;
private _ammo   = false;

{
    ([_x] call FUNC(supplyCapabilities)) params ["_r", "_f", "_a"];
    _repair = _repair || _r;
    _fuel   = _fuel   || _f;
    _ammo   = _ammo   || _a;
} forEach ([_objects] call FUNC(getSupplyVehicles));

// Only relabel when the selection points at exactly one of the three services
private _serviceCount = 0;
if (_repair) then {_serviceCount = _serviceCount + 1};
if (_fuel)   then {_serviceCount = _serviceCount + 1};
if (_ammo)   then {_serviceCount = _serviceCount + 1};

if (_serviceCount != 1) exitWith {};

if (_repair) exitWith {
    _action set [ACTION_INDEX_DISPLAYNAME, LLSTRING(ActionRepair)];
    _action set [ACTION_INDEX_ICON, ICON_REPAIR];
};

if (_fuel) exitWith {
    _action set [ACTION_INDEX_DISPLAYNAME, LLSTRING(ActionRefuel)];
    _action set [ACTION_INDEX_ICON, ICON_REFUEL];
};

_action set [ACTION_INDEX_DISPLAYNAME, LLSTRING(ActionRearm)];
_action set [ACTION_INDEX_ICON, ICON_REARM];
