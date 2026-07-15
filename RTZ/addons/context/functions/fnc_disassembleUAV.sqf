#include "script_component.hpp"
/*
 * rtz_fnc_disassembleUAV
 *
 * SERVER: lightweight pack path for an assembled drone. A UAV's "gunner" is its
 * throwaway AI crew, not a real carrier, so there is no dismount-and-fold
 * animation — the drone is simply removed and its bag returned to the operator who
 * deployed it (tagged at assemble time), or dropped on the ground if that operator
 * is gone / unknown (e.g. a Zeus-placed drone).
 *
 * Split out of the manned disassemble flow (FUNC(disassembleWeaponApply) routes
 * here for a UAV) so neither path carries the other's special-casing. Mirror of
 * FUNC(assembleUAV).
 *
 * Parameters:
 *   0: Object — the drone to pack
 *   1: String — weapon-bag class to return (assembleInfo source bag)
 */

params ["_weapon", ["_weaponBag", ""]];
if (isNull _weapon) exitWith {};

private _pos = getPosATL _weapon;
private _op = _weapon getVariable [QGVAR(assembleOperator), objNull];

{ _weapon deleteVehicleCrew _x } forEach (crew _weapon);
deleteVehicle _weapon;

if (_weaponBag != "") then {
    if (!isNull _op && {alive _op} && {isNull objectParent _op} && {backpack _op == ""}) then {
        _op addBackpackGlobal _weaponBag;
    } else {
        [_weaponBag, _pos] call FUNC(dropBag);
    };
};
