#include "script_component.hpp"
/*
 * Author: Maxim
 * Makes the unit plant a mine at its current position using the "Put" weapon.
 * Consumes the magazine and creates a mine known to the unit's side.
 * Must be executed where the unit is local.
 *
 * Arguments:
 * 0: Unit <OBJECT>
 * 1: Magazine <STRING>
 *
 * Return Value:
 * None
 *
 * Example:
 * [_unit, "ATMine_Range_Mag"] call rtz_mine_fnc_plantMine
 *
 * Public: No
 */

params ["_unit", "_magazine"];

private _muzzle = GVAR(muzzles) getOrDefault [toLowerANSI _magazine, ""];
if (_muzzle isEqualTo "") exitWith {};

_unit playActionNow "PutDown";
_unit selectWeapon _muzzle;
_unit fire [_muzzle, _muzzle, _magazine];

// Reset the "Put" weapon so further mines can be placed and return to the primary weapon
[{
    params ["_unit", "_muzzle"];

    if (!alive _unit) exitWith {};

    _unit setWeaponReloadingTime [_unit, _muzzle, 0];

    private _weapon = primaryWeapon _unit;

    if (_weapon isNotEqualTo "") then {
        _unit selectWeapon _weapon;
    };
}, [_unit, _muzzle], PUT_DELAY] call CBA_fnc_waitAndExecute;
