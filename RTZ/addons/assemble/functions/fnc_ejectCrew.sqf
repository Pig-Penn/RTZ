#include "script_component.hpp"
/*
 * Author: Maxim
 * Empty a weapon before it is removed. A corpse left in the seat silently blocks
 * deleteVehicle, so every pack path in FUNC(packWeapon) runs this first.
 *
 * AI crew spawned by createVehicleCrew (a drone's, or a Zeus-placed static's) is
 * deleted outright rather than dismounted - moveOut would leave loose bodies
 * standing around every packed weapon.
 *
 * Arguments:
 * 0: Weapon <OBJECT>
 *
 * Return Value:
 * None
 *
 * Example:
 * [_weapon] call rtz_assemble_fnc_ejectCrew
 *
 * Public: No
 */

params ["_weapon"];

{
    if (unitIsUAV _x) then {
        _weapon deleteVehicleCrew _x;
    } else {
        moveOut _x;
    };
} forEach (crew _weapon);
