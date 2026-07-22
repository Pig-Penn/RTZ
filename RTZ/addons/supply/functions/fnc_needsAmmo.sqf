#include "script_component.hpp"
/*
 * Author: Maxim
 * Whether any turret magazine of the vehicle is below its full round count.
 * There is no command that reads a vehicle's ammo ratio directly, so the loaded
 * magazines are compared against their configured size; the sizes are cached per
 * magazine class because the same handful of classes recur across every vehicle.
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

private _sizes = GVAR(magazineSizes);

(magazinesAllTurrets _vehicle findIf {
    _x params ["_magazine", "", "_rounds"];

    _rounds < (_sizes getOrDefaultCall [_magazine, {
        getNumber (configFile >> "CfgMagazines" >> _magazine >> "count")
    }, true])
}) > -1
