#include "script_component.hpp"
/*
 * Author: Maxim
 * Returns the selected vehicles that carry at least one of the three supplies.
 * Selecting a crewman resolves to his vehicle, so a fuel truck can be picked by
 * clicking its driver.
 *
 * Arguments:
 * 0: Selected Objects <ARRAY>
 *
 * Return Value:
 * Supply Vehicles <ARRAY>
 *
 * Example:
 * [_objects] call rtz_supply_fnc_getSupplyVehicles
 *
 * Public: No
 */

params [["_objects", [], [[]]]];

([_objects] call EFUNC(common,collectVehicles)) select {
    alive _x && { true in ([_x] call FUNC(supplyCapabilities)) }
}
