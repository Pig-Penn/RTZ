#include "script_component.hpp"
/*
 * Author: Maxim
 * Handler body for QGVAR(disassemble) (the receiver is registered in
 * XEH_postInit). Reverse of FUNC(assembleWeapon), routing one manned static, or
 * drone, to its pack path:
 *   - a drone is removed instantly and its bag returned to the operator
 *     (FUNC(disassembleUAV) - lightweight, no animation)
 *   - a manned static weapon is packed with the real engine disassemble animation:
 *     the support bag assistant walks over, then the gunner dismounts and folds it
 *     (FUNC(packWeapon))
 *
 * doMove, deleteVehicle and the disassemble action all need the weapon local, so the
 * whole errand lives here and FUNC(orderDisassemble) dispatches each set to its owner
 * with CBA_fnc_targetEvent - the server for ordinary Zeus AI, a headless client or a
 * player's machine for offloaded or player-led groups. Must be executed where the
 * weapon is local.
 *
 * Arguments:
 * 0: Static Weapon or Drone <OBJECT>
 * 1: Gunner <OBJECT> - objNull is resolved from the weapon here
 * 2: Weapon Bag <STRING> - handed to the gunner
 * 3: Support Bags <ARRAY of STRING> - the first entry is used, [] for single bag
 *    weapons (default: [])
 * 4: Curator's Player <OBJECT> - feedback toasts (default: objNull)
 *
 * Return Value:
 * None
 *
 * Example:
 * [_weapon, _gunner, "B_HMG_01_weapon_F", ["B_HMG_01_support_F"], player] call rtz_assemble_fnc_disassembleWeapon
 *
 * Public: No
 */

params ["_weapon", "_gunner", "_weaponBag", ["_baseBags", []], ["_curator", objNull]];

if (isNull _weapon) exitWith {};

if (!local _weapon) exitWith {
    [_curator, LLSTRING(WeaponNotLocal)] call FUNC(notifyCurator);
};

// A drone folds instantly back into its bag, no dismount animation. Lightweight,
// separate path (mirror of the assemble UAV split)
if (unitIsUAV _weapon) exitWith {
    [_weapon, _weaponBag] call FUNC(disassembleUAV);
};

if (!(_weapon isKindOf "StaticWeapon")) exitWith {};

if (isNull _gunner) then {
    _gunner = gunner _weapon;
};

if (isNull _gunner) exitWith {};

// Guard against a double right-click packing the same weapon twice. The flag lives
// on the weapon, which the pack deletes, so it needs no later clear
if (_weapon getVariable [QGVAR(packing), false]) exitWith {};
_weapon setVariable [QGVAR(packing), true];

private _baseBag = _baseBags param [0, ""];

// Single bag weapon such as the Mk6 mortar, the gunner packs it alone, in place, now
if (_baseBag isEqualTo "") exitWith {
    [_weapon, _gunner, _weaponBag, "", objNull, _curator] call FUNC(packWeapon);
};

// Two bag: find the man who takes the support bag before packing. Prefer the one who
// assembled it (tagged by FUNC(finishBuild)), else the nearest bagless groupmate on
// foot, skipping the group leader unless he is the only candidate
private _assistant = objNull;
private _tagged = _weapon getVariable [QGVAR(assistant), objNull];

if (!isNull _tagged && {alive _tagged} && {isNull objectParent _tagged} && {group _tagged == group _gunner} && {backpack _tagged == ""}) then {
    _assistant = _tagged;
} else {
    private _candidates = (units group _gunner) select {
        _x != _gunner && {alive _x} && {isNull objectParent _x} && {backpack _x == ""}
    };
    private _nonLeaders = _candidates select {_x != leader group _gunner};

    if (_nonLeaders isNotEqualTo []) then {
        _candidates = _nonLeaders;
    };

    _candidates = _candidates apply {[_x distance _gunner, _x]};
    _candidates sort true;

    if (_candidates isNotEqualTo []) then {
        _assistant = (_candidates select 0) select 1;
    };
};

// No taker available, pack alone - the support bag drops on the ground
if (isNull _assistant) exitWith {
    [_weapon, _gunner, _weaponBag, _baseBag, objNull, _curator] call FUNC(packWeapon);
};

// Instant disassembly: skip walking the assistant and pack now. FUNC(packWeapon)
// likewise skips the engine animation, and hands the support bag to the assistant
// regardless of his distance
if (GVAR(instant)) exitWith {
    [_weapon, _gunner, _weaponBag, _baseBag, _assistant, _curator] call FUNC(packWeapon);
};

// Walk the assistant to the weapon, then pack. Pack on arrival, or in place on the
// assistant's death or the timeout, so a Zeus order always completes
[
    [_assistant],
    getPosATL _weapon,
    ARRIVE_DISTANCE,
    WALK_TIMEOUT_BASE + (_assistant distance2D _weapon) * WALK_TIMEOUT_PER_METER,
    LINKFUNC(packWeapon),
    LINKFUNC(packWeapon),
    [_weapon, _gunner, _weaponBag, _baseBag, _assistant, _curator],
    true,
    _curator,
    LLSTRING(PackInPlace)
] call EFUNC(common,approach);
