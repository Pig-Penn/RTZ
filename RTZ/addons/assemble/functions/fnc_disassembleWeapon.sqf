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
    [_curator, LLSTRING(WeaponNotLocal)] call EFUNC(common,notifyCurator);
};

// Claim the weapon, so a double right-click can't pack it twice - and so the context
// menu (FUNC(collectDisassembleSets)) stops offering it. Public because the menu is
// filtered on the ordering curator's client while this runs wherever the weapon is
// local, which on a dedicated server is another machine entirely. Claimed before the
// drone split so a fast double order can't return two bags.
//
// A DEADLINE, not a flag - the same rule FUNC(assembleWeapon)'s QGVAR(assembling)
// claim follows, for the same reason. The two-bag path below hands the errand to
// EFUNC(common,approach) with the ASSISTANT as the walking lead, and an unrelated
// errand ordered onto that man mid-walk (a mine to lay, a vehicle to repair)
// supersedes this one inside approach - and a superseded order's hooks NEVER fire,
// neither arrival nor failure. A plain flag was stranded exactly there: the gunner
// stayed mounted and the weapon stayed "packing" - un-packable, silently, for the
// rest of the mission. The deadline lapses on its own instead. It starts at
// PACK_TIMEOUT, which covers every immediate path (drone, single-bag, instant);
// the walk path extends it once the assistant's walk length is known.
//
// Every path that goes on to pack deletes the weapon, taking the claim with it. The
// two that bail out below instead release it by hand, so a weapon this order can't
// pack doesn't sit out even the short deadline
if (CBA_missionTime < (_weapon getVariable [QGVAR(packing), 0])) exitWith {};
SETPVAR(_weapon,GVAR(packing),CBA_missionTime + PACK_TIMEOUT);

// A drone folds instantly back into its bag, no dismount animation. Lightweight,
// separate path (mirror of the assemble UAV split)
if (unitIsUAV _weapon) exitWith {
    [_weapon, _weaponBag] call FUNC(disassembleUAV);
};

if (!(_weapon isKindOf "StaticWeapon")) exitWith {
    SETPVAR(_weapon,GVAR(packing),nil);
};

if (isNull _gunner) then {
    _gunner = gunner _weapon;
};

// Nobody left in the seat to fold it - release the claim so a crew that mans it
// later can still be ordered to pack it
if (isNull _gunner) exitWith {
    SETPVAR(_weapon,GVAR(packing),nil);
};

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
    // Nearest bagless groupmate on foot, in one pass: the leader is only considered
    // once no ordinary rifleman is left, so a squad doesn't lose its leader to
    // carrying a tripod. Linear scan rather than a sort - a squad's worth of
    // candidates, and sort would be comparing arrays that hold objects
    private _leader = leader group _gunner;
    private _closest = 1e10;
    private _closestLeader = 1e10;
    private _fallback = objNull;

    {
        if (_x != _gunner && {alive _x} && {isNull objectParent _x} && {backpack _x == ""}) then {
            private _distance = _x distance _gunner;

            if (_x isEqualTo _leader) then {
                if (_distance < _closestLeader) then {
                    _closestLeader = _distance;
                    _fallback = _x;
                };
            } else {
                if (_distance < _closest) then {
                    _closest = _distance;
                    _assistant = _x;
                };
            };
        };
    } forEach (units group _gunner);

    if (isNull _assistant) then {
        _assistant = _fallback;
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
private _walkTimeout = WALK_TIMEOUT_BASE + (_assistant distance2D _weapon) * WALK_TIMEOUT_PER_METER;

// Extend the claim deadline over the walk plus the pack window, mirroring
// FUNC(assembleWeapon). If the assistant is re-tasked mid-walk the errand's hooks
// never fire (see the claim comment above), and this lapse is what un-strands the
// weapon afterwards
SETPVAR(_weapon,GVAR(packing),CBA_missionTime + _walkTimeout + PACK_TIMEOUT);

// Behind the weapon and off to one side rather than into the weapon's own square: the
// assistant only has to be within reach when the bags are handed out, and a
// destination he can stand on beats one the engine keeps pushing him out of
[
    [_assistant],
    _weapon getRelPos [CREW_SPREAD, PACK_SPREAD_BEARING],
    ARRIVE_DISTANCE,
    _walkTimeout,
    LINKFUNC(packWeapon),
    LINKFUNC(packWeapon),
    [_weapon, _gunner, _weaponBag, _baseBag, _assistant, _curator],
    true,
    _curator,
    LLSTRING(PackInPlace)
] call EFUNC(common,approach);
