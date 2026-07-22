#include "script_component.hpp"
/*
 * Author: Maxim
 * Whether a resupply order is possible: at least one selected vehicle carries
 * supplies and has something serviceable parked next to it. Drives the
 * visibility of the context menu action.
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

if (!GVAR(enabled)) exitWith {false};

private _supplies = [_objects] call FUNC(getSupplyVehicles);
if (_supplies isEqualTo []) exitWith {false};

// One serviceable vehicle anywhere in the selection is enough to offer the order
(_supplies findIf {
    ([_x, [_x] call FUNC(supplyCapabilities), true] call FUNC(findTargets)) isNotEqualTo []
}) > -1
