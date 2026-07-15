#include "script_component.hpp"
/*
 * rtz_fnc_disassemblePack
 *
 * SERVER: pack a manned static weapon back into backpacks using the real engine
 * disassemble action (authentic dismount-and-fold animation, mirror of the LAMBS
 * pack flow). The gunner leaves the weapon and issues action ["Disassemble"]; the
 * engine removes the static, spawns the weapon + support bags and fires
 * "WeaponDisassembled", whose EH has the gunner take the weapon bag and the
 * assistant the support bag.
 *
 * The engine action can silently no-op, so a deterministic fallback fires after
 * PACK_TIMEOUT: if the weapon is still there it is packed directly (the old
 * deleteVehicle + addBackpackGlobal path) so a Zeus command never fails quietly.
 * The state slot of the shared QGVAR(disCtx) on the gunner makes the EH and
 * fallback mutually exclusive — whichever fires first claims "done" and the other
 * bails. Crew (including a corpse in the seat, which would silently block
 * deleteVehicle) is always ejected before the weapon is removed; a gunner who died
 * mid-pack drops the bags on the ground instead of receiving one.
 *
 * Called by FUNC(disassembleWeaponApply) once the assistant has reached the weapon
 * (or immediately for a single-bag weapon).
 *
 * Parameters:
 *   0: Object — static weapon to pack
 *   1: Object — gunner (performs the pack, receives the weapon bag)
 *   2: String — weapon-bag class (fallback path; engine path uses the spawned bag)
 *   3: String — support-bag class ("" for single-bag; fallback path)
 *   4: Object — assistant receiving the support bag (objNull for single-bag)
 *   5: Object — ordering curator's player (feedback toasts; may be objNull)
 */

// Seconds to wait for the engine "WeaponDisassembled" before forcing the pack.
#define PACK_TIMEOUT 6

params ["_weapon", "_gunner", ["_weaponBag", ""], ["_baseBag", ""], ["_assistant", objNull], ["_curator", objNull]];

if (isNull _weapon) exitWith { [_gunner, _assistant] call FUNC(disassembleFinalize); };

private _pos = getPosATL _weapon;
private _dir = getDir _weapon;

// Eject everyone (a corpse left in the seat silently blocks deleteVehicle).
private _fnc_ejectCrew = {
    params ["_weapon"];
    {
        if (unitIsUAV _x) then { _weapon deleteVehicleCrew _x } else { moveOut _x };
    } forEach (crew _weapon);
};

// Gunner gone — can't animate a pack. Drop the weapon and scatter the bags.
if (isNull _gunner || {!alive _gunner}) exitWith {
    [_weapon] call _fnc_ejectCrew;
    deleteVehicle _weapon;
    [_weaponBag, _pos] call FUNC(dropBag);
    [_baseBag, _pos vectorAdd [sin _dir, cos _dir, 0]] call FUNC(dropBag);
    [_gunner, _assistant] call FUNC(disassembleFinalize);
    [_curator, "Packed"] call FUNC(assembleToast);
};

// One transient context var on the gunner: [state, assistant, curator, EH id].
// SQF arrays are by reference, so the EH-id slot set below is seen by the stored
// copy. "pending" until the EH or the fallback claims the pack; the assistant and
// curator ride along because the EH's own scope can't capture them from here.
private _ctx = ["pending", _assistant, _curator, -1];
_gunner setVariable [QGVAR(disCtx), _ctx];

// Deterministic pack: delete the static and hand the bags back directly, no engine
// animation. Shared by the instant path (below) and the timeout fallback — the
// ctx state slot keeps it mutually exclusive with the "WeaponDisassembled" EH, so
// whichever fires first claims "done".
private _fnc_directPack = {
    params ["_weapon", "_gunner", "_weaponBag", "_baseBag", "_assistant", "_fnc_ejectCrew"];
    if (isNull _gunner) exitWith {};
    private _ctx = _gunner getVariable [QGVAR(disCtx), []];
    if ((_ctx param [0, ""]) isNotEqualTo "pending") exitWith {};
    _ctx set [0, "done"];
    private _eh = _ctx param [3, -1];
    if (_eh >= 0) then { _gunner removeEventHandler ["WeaponDisassembled", _eh]; };

    if (isNull _weapon) exitWith { [_gunner, _assistant] call FUNC(disassembleFinalize); };
    private _p = getPosATL _weapon;
    private _d = getDir _weapon;
    [_weapon] call _fnc_ejectCrew;
    if (alive _gunner) then {
        (group _gunner) leaveVehicle _weapon;
        unassignVehicle _gunner;
    };
    deleteVehicle _weapon;
    // A gunner who died inside the animation window gets no bag — drop it instead.
    if (alive _gunner && {_weaponBag != ""}) then {
        _gunner addBackpackGlobal _weaponBag;
    } else {
        [_weaponBag, _p] call FUNC(dropBag);
    };
    if (_baseBag != "") then {
        if (!isNull _assistant && {alive _assistant} && {isNull objectParent _assistant} && {backpack _assistant == ""}) then {
            _assistant addBackpackGlobal _baseBag;
        } else {
            [_baseBag, _p vectorAdd [sin _d, cos _d, 0]] call FUNC(dropBag);
        };
    };
    if (!alive _gunner) then {
        [_ctx param [2, objNull], "Packed"] call FUNC(assembleToast);
    };
    [_gunner, _assistant] call FUNC(disassembleFinalize);
};

// Instant disassembly (CBA setting): skip the engine animation, pack immediately.
if (GETGVAR(instantAssemble,false)) exitWith {
    [_weapon, _gunner, _weaponBag, _baseBag, _assistant, _fnc_ejectCrew] call _fnc_directPack;
};

// EH: the engine folded the weapon and spawned the bag objects.
private _eh = _gunner addEventHandler ["WeaponDisassembled", {
    params ["_unit", "_weaponBagObj", "_baseBagObj"];
    private _ctx = _unit getVariable [QGVAR(disCtx), []];
    if ((_ctx param [0, ""]) isEqualTo "pending") then {
        _ctx set [0, "done"];
        _unit removeEventHandler ["WeaponDisassembled", _thisEventHandler];
        private _asst = _ctx param [1, objNull];
        // Hand the bags to the same men (gunner: weapon, assistant: support).
        if (!isNull _weaponBagObj) then { _unit action ["TakeBag", _weaponBagObj]; };
        if (!isNull _asst && {!isNull _baseBagObj}) then { _asst action ["TakeBag", _baseBagObj]; };
        [_unit, _asst] call FUNC(disassembleFinalize);
    };
}];
_ctx set [3, _eh];

// Dismount and issue the real disassemble action.
moveOut _gunner;
(group _gunner) leaveVehicle _weapon;
unassignVehicle _gunner;
_gunner action ["Disassemble", _weapon];

// Deterministic fallback: if the engine never fired, pack it directly.
[_fnc_directPack, [_weapon, _gunner, _weaponBag, _baseBag, _assistant, _fnc_ejectCrew], PACK_TIMEOUT] call CBA_fnc_waitAndExecute;
