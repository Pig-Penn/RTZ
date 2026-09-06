#include "script_component.hpp"
/*
 * Author: Maxim
 * Whether a resupply order is possible: at least one selected vehicle carries
 * supplies and has something serviceable parked next to it. Drives the
 * visibility of the context menu action.
 *
 * This only decides whether the PICKER is worth opening. Which vehicle is actually
 * serviced is FUNC(orderResupply)'s question, asked at the cursor — but the entry
 * must not be offered when no click could succeed, which is what this answers.
 *
 * This is the hot path — ZEN re-evaluates it every time the menu is built — so both
 * loops stop at the first hit: FUNC(hasServiceWork) short-circuits on the first
 * serviceable vehicle it finds, and the findIf here stops at the first supply
 * vehicle that has any work.
 *
 * Arguments:
 * 0: Selected Objects <ARRAY>
 *
 * Return Value:
 * Order Possible <BOOL>
 *
 * Example:
 * [_objects] call rtz_supply_fnc_canResupply
 *
 * Public: No
 */

params ["_objects"];

if (!GVAR(enabled)) exitWith { false };

private _supplies = [_objects] call FUNC(getSupplyVehicles);
if (_supplies isEqualTo []) exitWith { false };

// One serviceable vehicle anywhere in the selection is enough to offer the order
(_supplies findIf {
    [_x, [_x] call FUNC(supplyCapabilities)] call FUNC(hasServiceWork)
}) > -1
