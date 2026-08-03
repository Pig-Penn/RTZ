#include "script_component.hpp"
/*
 * Author: Maxim
 * Whether a pile of magazines holds anything the unit's CURRENT weapons can fire.
 *
 * This is what makes an ammunition crate a valid destination in its own right. A
 * squad low on rounds standing next to a full crate has to be worth a walk even
 * though there is not a single weapon, vest or helmet in it to take - and without
 * this test FUNC(lootPlan) would return an empty plan for exactly that case and the
 * dispatcher would skip the crate entirely.
 *
 * All three weapon slots are consulted, handgun included: the magazine list comes
 * from FUNC(weaponScore), which caches it for every weapon class it sees regardless
 * of whether that class fills a slot the looter would ever take from.
 *
 * Arguments:
 * 0: Unit <OBJECT>
 * 1: Magazines <ARRAY of STRING> - what the target has on offer
 *
 * Return Value:
 * Anything usable <BOOL>
 *
 * Example:
 * private _worthIt = [_unit, magazineCargo _crate] call rtz_loot_fnc_offersAmmo;
 *
 * Public: No
 */

params ["_unit", "_offered"];

if (_offered isEqualTo []) exitWith {false};

[primaryWeapon _unit, secondaryWeapon _unit, handgunWeapon _unit] findIf {
    _x isNotEqualTo ""
    && {
        private _magazines = ([_x] call FUNC(weaponScore)) select 3;

        _offered findIf {_x in _magazines} > -1
    }
} > -1
