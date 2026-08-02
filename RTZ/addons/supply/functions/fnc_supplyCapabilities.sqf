#include "script_component.hpp"
/*
 * Author: Maxim
 * Returns what a vehicle can hand out, read from the same transport* config
 * entries the engine's own support modules use. The answer only depends on the
 * class name, so it is cached per class - the context menu condition would
 * otherwise re-read three config entries per selected vehicle on every open.
 *
 * Only the SIGN of each entry is meaningful. The magnitudes are Operation
 * Flashpoint-era leftovers on three unrelated scales — a stock fuel truck reads
 * transportFuel = 3000, an ammo truck transportAmmo = 300000 and a repair truck
 * transportRepair = 200000000 — so they cannot be compared with each other or
 * read as a stock level. (ACE3 reached the same conclusion and defines its own
 * ace_refuel_fuelCargo rather than touching these.) They are used here strictly
 * as the three booleans "this class is a fuel / ammo / repair vehicle", which is
 * exactly what the engine uses them for too.
 *
 * Arguments:
 * 0: Vehicle <OBJECT>
 *
 * Return Value:
 * 0: Can Repair <BOOL>
 * 1: Can Refuel <BOOL>
 * 2: Can Rearm <BOOL>
 *
 * Example:
 * [_vehicle] call rtz_supply_fnc_supplyCapabilities
 *
 * Public: No
 */

params ["_vehicle"];

GVAR(capabilities) getOrDefaultCall [typeOf _vehicle, {
    private _config = configOf _vehicle;

    [
        getNumber (_config >> "transportRepair") > 0,
        getNumber (_config >> "transportFuel") > 0,
        getNumber (_config >> "transportAmmo") > 0
    ]
}, true]
