#include "script_component.hpp"
/*
 * rtz_fnc_lootFromTarget
 *
 * One unit loots one lootable target it is standing next to. Runs on the
 * SERVER (units local there for Zeus AI), called by FUNC(lootNearbyApply)
 * when the unit arrives. Scope is loadout OPTIMIZATION: a slot is swapped
 * whenever the target holds something strictly better, not only when the
 * unit's own slot is empty.
 *
 *   - primary weapon → take if empty, or swap up a rank (rifle/SMG/shotgun
 *                      < sniper rifle/machine gun)
 *   - launcher       → take if empty, or swap a rocket launcher for a
 *                      missile launcher (guided beats unguided)
 *   - vest           → take if empty, or swap for higher chest armor value
 *                      (contents transferred, LAMBS doCheckBody pattern)
 *   - headgear       → take if unarmored and the target's is armored
 *   - backpack       → take if empty (contents included) — capacity has no
 *                      config-exposed rank to compare, so this stays gap-fill
 *   - ammo           → engine "rearm" action last, so magazines for anything
 *                      just taken are picked up too
 *
 * The engine actions play pickup animations and handle the networked
 * inventory sync, so the loot looks natural and needs no manual cargo
 * bookkeeping. All calls no-op gracefully when the target was emptied by a
 * co-claimant.
 *
 * Parameters:
 *   0: Object — unit doing the looting
 *   1: Object — lootable target (corpse, weapon holder, crate, vehicle)
 */

params ["_unit", "_target"];

private _isBody = _target isKindOf "CAManBase";

// Weapons on offer: worn weapons for a corpse, weapon cargo otherwise.
private _wpns = if (_isBody) then { weapons _target } else { (getWeaponCargo _target) select 0 };

// Rank a weapon within its own slot category; 0 = not eligible for that slot.
// Sniper rifles / machine guns outrank plain rifles-SMGs-shotguns; missile
// launchers (guided) outrank rocket launchers (unguided).
private _fnc_weaponRank = {
    params ["_cls", "_isLauncher"];
    private _base = [_cls] call BIS_fnc_baseWeapon;
    private _rank = 0;
    if (_isLauncher) then {
        if (_base in allMissileLaunchers) then { _rank = 2 };
        if (_rank == 0 && {_base in allRocketLaunchers}) then { _rank = 1 };
    } else {
        if (_base in allSniperRifles || {_base in allMachineGuns}) then { _rank = 2 };
        if (_rank == 0 && {(_base in allRifles) || {_base in allSMGs} || {_base in allShotguns}}) then { _rank = 1 };
    };
    _rank
};

// CfgWeapons "type": 1 = primary, 4 = launcher. Take if empty, or swap up a rank.
if (_wpns isNotEqualTo []) then {
    private _rank = if (primaryWeapon _unit isEqualTo "") then { 0 } else { [primaryWeapon _unit, false] call _fnc_weaponRank };
    private _i = _wpns findIf {
        getNumber (configFile >> "CfgWeapons" >> _x >> "type") == TYPE_WEAPON_PRIMARY
        && {([_x, false] call _fnc_weaponRank) > _rank}
    };
    if (_i > -1) then { _unit action ["TakeWeapon", _target, _wpns select _i] };
};
if (_wpns isNotEqualTo []) then {
    private _rank = if (secondaryWeapon _unit isEqualTo "") then { 0 } else { [secondaryWeapon _unit, true] call _fnc_weaponRank };
    private _i = _wpns findIf {
        getNumber (configFile >> "CfgWeapons" >> _x >> "type") == TYPE_WEAPON_SECONDARY
        && {([_x, true] call _fnc_weaponRank) > _rank}
    };
    if (_i > -1) then { _unit action ["TakeWeapon", _target, _wpns select _i] };
};

// Corpse-only: backpack, vest and headgear transfers keep their contents by
// re-adding the items after the swap (matches LAMBS fnc_doCheckBody). Vest
// and headgear swap up on protection; backpack has no comparable rank, so it
// stays gap-fill.
if (_isBody) then {
    if (backpack _unit isEqualTo "" && {backpack _target isNotEqualTo ""}) then {
        private _items = backpackItems _target;
        private _bp = backpack _target;
        removeBackpackGlobal _target;
        _unit addBackpack _bp;
        { _unit addItemToBackpack _x } forEach _items;
    };

    private _fnc_chestArmor = {
        params ["_vest"];
        if (_vest isEqualTo "") exitWith { -1 };
        getNumber (configFile >> "CfgWeapons" >> _vest >> "ItemInfo" >> "HitpointsProtectionInfo" >> "Chest" >> "armor")
    };
    if (([vest _target] call _fnc_chestArmor) > ([vest _unit] call _fnc_chestArmor)) then {
        private _items = vestItems _target;
        private _v = vest _target;
        removeVest _target;
        _unit addVest _v;
        { _unit addItemToVest _x } forEach _items;
    };

    if (!(headgear _unit in allArmoredHeadgear) && {headgear _target in allArmoredHeadgear}) then {
        private _hg = headgear _target;
        removeHeadgear _target;
        _unit addHeadgear _hg;
    };
};

// Last: engine rearm tops up magazines for the unit's current weapons,
// including anything just taken above.
_unit action ["rearm", _target];
