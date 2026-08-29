#include "script_component.hpp"
/*
 * Author: Maxim
 * Returns what a supply vehicle can hand out RIGHT NOW, read from the engine's
 * own cargo levels rather than from config.
 *
 * getRepairCargo / getFuelCargo / getAmmoCargo return -1 for an object that has
 * no such cargo at all, and 0..1 otherwise. That single pair of facts covers both
 * halves of the question this component needs answered:
 *
 *   != -1  — this object IS a repair / fuel / ammo source
 *   >   0  — and it still has stock
 *
 * Testing `> 0` therefore answers both at once, and is what makes depletion work
 * with no bookkeeping anywhere: the engine's service actions consume these pools,
 * a truck that runs dry stops reporting the capability, FUNC(getSupplyVehicles)
 * drops it, and the ZEN context action disappears on its own. Zeus Wargame
 * classifies supply points with the same three getters.
 *
 * This replaces a class-keyed cache of the transport* config entries. Those are
 * Operation Flashpoint-era leftovers on three unrelated scales — a stock fuel
 * truck reads transportFuel = 3000, an ammo truck transportAmmo = 300000, a
 * repair truck transportRepair = 200000000 — so only their SIGN could be used,
 * which made every truck in the mission infinite. The cache is gone with them and
 * must not come back: the value is per OBJECT and falls as the truck is used, so
 * caching it by class would not be stale, it would be the one number the whole
 * model rests on read from the wrong thing.
 *
 * Three engine getters are cheaper than the config reads the cache existed to
 * avoid, and this runs against a bounded selection, never per entity per frame.
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

[
    getRepairCargo _vehicle > 0,
    getFuelCargo _vehicle > 0,
    getAmmoCargo _vehicle > 0
]
