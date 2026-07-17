#include "script_component.hpp"
/*
 * Author: Maxim
 * One unit loots one lootable target it is standing next to. SERVER (the unit must be
 * local), called by FUNC(lootSquads) when the unit arrives. The scope is loadout
 * OPTIMIZATION: a slot is swapped whenever the target holds something strictly
 * better, not only when the unit's own slot is empty.
 *
 *   - primary weapon -> take if empty, or swap up a rank (rifle/SMG/shotgun <
 *                       sniper rifle/machine gun)
 *   - launcher       -> take if empty, or swap a rocket launcher for a missile
 *                       launcher (guided beats unguided)
 *   - vest           -> take if empty, or swap for higher chest armor (contents
 *                       transferred, LAMBS doCheckBody pattern)
 *   - headgear       -> take if unarmored and the target's is armored
 *   - backpack       -> take if empty (contents included) - capacity has no
 *                       config-exposed rank to compare, so this stays gap-fill
 *   - ammo           -> engine "rearm" action last, so magazines for anything just
 *                       taken are picked up too
 *
 * The engine actions play the pickup animations and handle the networked inventory
 * sync, so the loot looks natural and needs no manual cargo bookkeeping. Every call
 * no-ops gracefully when the target was already emptied by a co-claimant.
 *
 * Arguments:
 * 0: Unit <OBJECT> - the unit doing the looting
 * 1: Target <OBJECT> - corpse, weapon holder, crate or vehicle
 *
 * Return Value:
 * None
 *
 * Example:
 * [_unit, _target] call rtz_loot_fnc_lootTarget
 *
 * Public: No
 */

params ["_unit", "_target"];

private _isBody = _target isKindOf "CAManBase";

// Weapons on offer: the worn weapons for a corpse, the weapon cargo otherwise
private _weapons = if (_isBody) then {weapons _target} else {(getWeaponCargo _target) select 0};

// Rank a weapon within its own slot category, 0 = not eligible for that slot. Sniper
// rifles / machine guns outrank plain rifles-SMGs-shotguns, missile launchers
// (guided) outrank rocket launchers (unguided)
private _fnc_weaponRank = {
    params ["_class", "_isLauncher"];

    private _base = [_class] call BIS_fnc_baseWeapon;
    private _rank = 0;

    if (_isLauncher) then {
        if (_base in allMissileLaunchers) then {
            _rank = 2;
        } else {
            if (_base in allRocketLaunchers) then {_rank = 1};
        };
    } else {
        if (_base in allSniperRifles || {_base in allMachineGuns}) then {
            _rank = 2;
        } else {
            if (_base in allRifles || {_base in allSMGs} || {_base in allShotguns}) then {_rank = 1};
        };
    };

    _rank
};

// CfgWeapons "type" is the engine's slot flag. Take if the slot is empty, or swap up
// a rank. An empty slot ranks 0, which every eligible weapon beats
if (_weapons isNotEqualTo []) then {
    {
        _x params ["_type", "_isLauncher", "_current"];

        private _rank = if (_current isEqualTo "") then {0} else {[_current, _isLauncher] call _fnc_weaponRank};
        private _index = _weapons findIf {
            getNumber (configFile >> "CfgWeapons" >> _x >> "type") == _type
            && {([_x, _isLauncher] call _fnc_weaponRank) > _rank}
        };

        if (_index > -1) then {
            _unit action ["TakeWeapon", _target, _weapons select _index];
        };
    } forEach [
        [TYPE_WEAPON_PRIMARY, false, primaryWeapon _unit],
        [TYPE_WEAPON_SECONDARY, true, secondaryWeapon _unit]
    ];
};

// Corpse-only: the backpack, vest and headgear transfers keep their contents by
// re-adding the items after the swap (matches LAMBS fnc_doCheckBody). Vest and
// headgear swap up on protection, backpack has no comparable rank so it stays
// gap-fill
if (_isBody) then {
    if (backpack _unit isEqualTo "" && {backpack _target isNotEqualTo ""}) then {
        private _items = backpackItems _target;
        private _backpack = backpack _target;

        removeBackpackGlobal _target;
        _unit addBackpack _backpack;

        {
            _unit addItemToBackpack _x;
        } forEach _items;
    };

    private _fnc_chestArmor = {
        params ["_vest"];

        if (_vest isEqualTo "") exitWith {-1};

        getNumber (configFile >> "CfgWeapons" >> _vest >> "ItemInfo" >> "HitpointsProtectionInfo" >> "Chest" >> "armor")
    };

    if (([vest _target] call _fnc_chestArmor) > ([vest _unit] call _fnc_chestArmor)) then {
        private _items = vestItems _target;
        private _vest = vest _target;

        removeVest _target;
        _unit addVest _vest;

        {
            _unit addItemToVest _x;
        } forEach _items;
    };

    if (!(headgear _unit in allArmoredHeadgear) && {headgear _target in allArmoredHeadgear}) then {
        private _headgear = headgear _target;

        removeHeadgear _target;
        _unit addHeadgear _headgear;
    };
};

// Last: the engine rearm tops up the magazines for the unit's current weapons,
// including anything just taken above
_unit action ["rearm", _target];
