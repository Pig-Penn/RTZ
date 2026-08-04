#include "script_component.hpp"
/*
 * Author: Maxim
 * Pack a manned static weapon back into backpacks using the real engine
 * disassemble action (the authentic dismount-and-fold animation, mirror of the LAMBS
 * pack flow). The gunner leaves the weapon and issues action ["Disassemble"], the
 * engine removes the static, spawns the weapon and support bags and fires
 * "WeaponDisassembled", whose handler has the gunner take the weapon bag and the
 * assistant the support bag.
 *
 * The engine action can silently no-op, so a deterministic fallback fires after
 * PACK_TIMEOUT: if the weapon is still there it is packed directly (a plain
 * deleteVehicle + addBackpackGlobal) so a Zeus order never fails quietly. The state
 * slot of the shared QGVAR(packCtx) on the gunner makes the event handler and the
 * fallback mutually exclusive - whichever fires first claims "done" and the other
 * bails. Crew (including a corpse in the seat, which would silently block
 * deleteVehicle) is always ejected before the weapon is removed - FUNC(ejectCrew) -
 * and a gunner who died mid-pack drops the bags on the ground instead of receiving
 * one.
 *
 * Called by FUNC(disassembleWeapon) once the assistant has reached the weapon, or
 * immediately for a single bag weapon. Must be executed where the weapon is local.
 *
 * Arguments:
 * 0: Static Weapon <OBJECT>
 * 1: Gunner <OBJECT> - performs the pack and receives the weapon bag
 * 2: Weapon Bag <STRING> - fallback path only, the engine path uses the spawned bag
 *    (default: "")
 * 3: Support Bag <STRING> - "" for single bag weapons, fallback path only (default: "")
 * 4: Assistant <OBJECT> - receives the support bag, objNull for single bag (default: objNull)
 * 5: Curator's Player <OBJECT> - feedback toasts (default: objNull)
 *
 * Return Value:
 * None
 *
 * Example:
 * [_weapon, _gunner, "B_HMG_01_weapon_F", "B_HMG_01_support_F", _assistant, player] call rtz_assemble_fnc_packWeapon
 *
 * Public: No
 */

params ["_weapon", "_gunner", ["_weaponBag", ""], ["_baseBag", ""], ["_assistant", objNull], ["_curator", objNull]];

if (isNull _weapon) exitWith {
    [_gunner, _assistant, objNull] call FUNC(finishPack);
};

// Gunner gone, nobody can animate a pack. Drop the weapon and scatter the bags
if (isNull _gunner || {!alive _gunner}) exitWith {
    private _position = getPosATL _weapon;
    private _direction = getDir _weapon;

    [_weapon] call FUNC(ejectCrew);
    deleteVehicle _weapon;
    [_weaponBag, _position] call FUNC(dropBag);
    [_baseBag, _position vectorAdd [sin _direction, cos _direction, 0]] call FUNC(dropBag);
    [_gunner, _assistant, _weapon] call FUNC(finishPack);
    [_curator, LLSTRING(Packed)] call EFUNC(common,notifyCurator);
};

// One transient context var on the gunner: [state, assistant, curator, EH id, weapon].
// SQF arrays are by reference, so the EH id slot set below is seen by the stored copy.
// "pending" until the event handler or the fallback claims the pack, the assistant,
// curator and weapon ride along because the event handler's own scope can't capture
// them from here - and unlike WeaponAssembled, WeaponDisassembled doesn't pass the
// static back as an argument, so the handler has no other way to reach it for cleanup
private _ctx = ["pending", _assistant, _curator, -1, _weapon];
_gunner setVariable [QGVAR(packCtx), _ctx];

// Deterministic pack: delete the static and hand the bags back directly, no engine
// animation. Shared by the instant path below and the timeout fallback - the ctx
// state slot keeps it mutually exclusive with the "WeaponDisassembled" handler, so
// whichever fires first claims "done"
private _fnc_directPack = {
    params ["_weapon", "_gunner", "_weaponBag", "_baseBag", "_assistant"];

    if (isNull _gunner) exitWith {};

    private _ctx = _gunner getVariable [QGVAR(packCtx), []];
    if ((_ctx param [0, ""]) isNotEqualTo "pending") exitWith {};
    _ctx set [0, "done"];

    private _eh = _ctx param [3, -1];

    if (_eh >= 0) then {
        _gunner removeEventHandler ["WeaponDisassembled", _eh];
    };

    if (isNull _weapon) exitWith {
        [_gunner, _assistant, objNull] call FUNC(finishPack);
    };

    private _position = getPosATL _weapon;
    private _direction = getDir _weapon;

    [_weapon] call FUNC(ejectCrew);

    if (alive _gunner) then {
        (group _gunner) leaveVehicle _weapon;
        unassignVehicle _gunner;
    };

    deleteVehicle _weapon;

    // A gunner who died inside the animation window gets no bag, drop it instead
    if (alive _gunner && {_weaponBag != ""}) then {
        _gunner addBackpackGlobal _weaponBag;
    } else {
        [_weaponBag, _position] call FUNC(dropBag);
    };

    if (_baseBag != "") then {
        if (!isNull _assistant && {alive _assistant} && {isNull objectParent _assistant} && {backpack _assistant == ""}) then {
            _assistant addBackpackGlobal _baseBag;
        } else {
            [_baseBag, _position vectorAdd [sin _direction, cos _direction, 0]] call FUNC(dropBag);
        };
    };

    if (!alive _gunner) then {
        [_ctx param [2, objNull], LLSTRING(Packed)] call EFUNC(common,notifyCurator);
    };

    [_gunner, _assistant, _weapon] call FUNC(finishPack);
};

// Instant disassembly: skip the engine animation, pack immediately
if (GVAR(instant)) exitWith {
    [_weapon, _gunner, _weaponBag, _baseBag, _assistant] call _fnc_directPack;
};

// The engine folded the weapon and spawned the bag objects
private _eh = _gunner addEventHandler ["WeaponDisassembled", {
    params ["_unit", "_weaponBagObject", "_baseBagObject"];

    private _ctx = _unit getVariable [QGVAR(packCtx), []];

    if ((_ctx param [0, ""]) isEqualTo "pending") then {
        _ctx set [0, "done"];
        _unit removeEventHandler ["WeaponDisassembled", _thisEventHandler];

        private _assistant = _ctx param [1, objNull];

        // Hand the bags to the same men (gunner: weapon, assistant: support)
        if (!isNull _weaponBagObject) then {
            _unit action ["TakeBag", _weaponBagObject];
        };

        if (!isNull _assistant && {!isNull _baseBagObject}) then {
            _assistant action ["TakeBag", _baseBagObject];
        };

        // The engine's own action doesn't reliably remove the static once the gunner
        // was dismounted ahead of it (see moveOut/leaveVehicle/unassignVehicle above) -
        // clean it up here rather than trust the animation to do it
        private _packed = _ctx param [4, objNull];
        deleteVehicle _packed;

        [_unit, _assistant, _packed] call FUNC(finishPack);
    };
}];
_ctx set [3, _eh];

// Dismount and issue the real disassemble action
moveOut _gunner;
(group _gunner) leaveVehicle _weapon;
unassignVehicle _gunner;
_gunner action ["Disassemble", _weapon];

// Deterministic fallback: if the engine never fired, pack it directly
[_fnc_directPack, [_weapon, _gunner, _weaponBag, _baseBag, _assistant], PACK_TIMEOUT] call CBA_fnc_waitAndExecute;
