#include "script_component.hpp"
/*
 * Author: Maxim
 * Lightweight pack path for an assembled drone. A UAV's "gunner" is its
 * throwaway AI crew, not a real carrier, so there is no dismount-and-fold animation:
 * the drone is simply removed and its bag returned to the operator who deployed it
 * (tagged by FUNC(assembleUAV)), or dropped on the ground if that operator is gone
 * or unknown, as for a Zeus-placed drone.
 *
 * Split out of the manned disassemble flow (FUNC(disassembleWeapon) routes here for
 * a UAV) so neither path carries the other's special casing. Mirror of
 * FUNC(assembleUAV).
 *
 * Arguments:
 * 0: Drone <OBJECT>
 * 1: Weapon Bag <STRING> - the assembleInfo source bag to return (default: "")
 *
 * Return Value:
 * None
 *
 * Example:
 * [_drone, "B_UAV_01_backpack_F"] call rtz_assemble_fnc_disassembleUAV
 *
 * Public: No
 */

params ["_weapon", ["_weaponBag", ""]];

if (isNull _weapon) exitWith {};

private _position = getPosATL _weapon;
private _operator = _weapon getVariable [QGVAR(operator), objNull];

[_weapon] call FUNC(ejectCrew);
deleteVehicle _weapon;

if (_weaponBag != "") then {
    if (!isNull _operator && {alive _operator} && {isNull objectParent _operator} && {backpack _operator == ""}) then {
        _operator addBackpackGlobal _weaponBag;
    } else {
        [_weaponBag, _position] call FUNC(dropBag);
    };
};
