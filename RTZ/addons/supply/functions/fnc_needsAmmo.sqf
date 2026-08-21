#include "script_component.hpp"
/*
 * Author: Maxim
 * Whether any turret magazine of the vehicle is below its full round count.
 * There is no command that reads a vehicle's ammo ratio directly, so the loaded
 * magazines are compared against their configured size — through
 * EFUNC(common,magazineCapacity), which caches per magazine class because the
 * same handful of classes recur across every vehicle, and which EFUNC(control,
 * needsReload) asks the identical question of.
 *
 * Arguments:
 * 0: Vehicle <OBJECT>
 *
 * Return Value:
 * Needs Rearming <BOOL>
 *
 * Example:
 * [_vehicle] call rtz_supply_fnc_needsAmmo
 *
 * Public: No
 */

params ["_vehicle"];

(magazinesAllTurrets _vehicle findIf {
    _x params ["_magazine", "", "_rounds"];

    _rounds < ([_magazine] call EFUNC(common,magazineCapacity))
}) > -1
