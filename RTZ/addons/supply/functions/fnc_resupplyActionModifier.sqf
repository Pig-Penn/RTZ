#include "script_component.hpp"
/*
 * Author: Maxim
 * CfgContext modifierFunction for the resupply order (see CfgContext.hpp).
 * Mutates the action's displayName and icon to name the single service being
 * offered when every selected supply vehicle carries the same one — e.g.
 * selecting only a fuel truck relabels the entry "Refuel" with the refuel
 * icon. A mixed selection (a fuel truck alongside an ammo truck, or a single
 * vehicle that carries more than one supply) falls back to the generic
 * "Resupply" truck icon, since no single label would describe the order.
 *
 * The decision itself is FUNC(serviceLabel)'s, because FUNC(orderResupply) needs
 * the same answer: the picker's valid-state cursor text is this entry's label, so
 * the cursor names the exact action the menu promised rather than a second wording
 * that has to be kept in step by hand.
 *
 * The generic pair is written back explicitly rather than left to the values in
 * CfgContext.hpp. ZEN hands the same action array to the modifier on every rebuild,
 * so a mixed selection following a single-service one would otherwise keep the
 * previous selection's label.
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

([[_objects] call FUNC(getSupplyVehicles)] call FUNC(serviceLabel)) params ["_key", "_icon"];

_action set [ACTION_INDEX_DISPLAYNAME, localize _key];
_action set [ACTION_INDEX_ICON, _icon];
