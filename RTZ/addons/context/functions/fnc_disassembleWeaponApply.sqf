#include "script_component.hpp"
/*
 * rtz_fnc_disassembleWeaponApply
 *
 * SERVER handler body for QGVAR(disassembleWeaponApply) (registered in XEH_postInit).
 * Reverse of FUNC(assembleWeaponApply): routes one manned static (or drone) to its
 * pack path:
 *   - a drone is removed instantly and its bag returned to the operator
 *     (FUNC(disassembleUAV) — lightweight, no animation);
 *   - a manned static weapon is packed with the real engine disassemble animation:
 *     the support-bag assistant walks over, then the gunner dismounts and folds it
 *     (FUNC(disassemblePack)).
 *
 * doMove / deleteVehicle / the disassemble action must run where the units are
 * local (the server, for AI in Zeus PvP), so the whole errand lives here. The
 * client action (FUNC(disassembleWeaponAction)) dispatches each set via
 * CBA_fnc_serverEvent.
 *
 * Parameters:
 *   0: Object — static weapon (or drone) to pack
 *   1: Object — its gunner (objNull → resolved here)
 *   2: String — weapon-bag class handed to the gunner
 *   3: Array  — support-bag class list (first entry used; [] for single-bag)
 *   4: Object — ordering curator's player (feedback toasts; may be objNull)
 */

params ["_weapon", "_gunner", "_weaponBag", ["_baseBags", []], ["_curator", objNull]];
if (isNull _weapon) exitWith {};
if (!local _weapon) exitWith {
    [_curator, "Weapon is not on this machine"] call FUNC(assembleToast);
};

// A drone folds instantly back into its bag — no dismount animation. Lightweight,
// separate path (mirror of the assemble UAV split).
if (unitIsUAV _weapon) exitWith {
    [_weapon, _weaponBag] call FUNC(disassembleUAV);
};
if (!(_weapon isKindOf "StaticWeapon")) exitWith {};

if (isNull _gunner) then { _gunner = gunner _weapon; };
if (isNull _gunner) exitWith {};

// Guard against a double right-click packing the same weapon twice.
if (_weapon getVariable [QGVAR(disassembling), false]) exitWith {};
_weapon setVariable [QGVAR(disassembling), true];

private _baseBag = _baseBags param [0, ""];

// Single-bag weapon (e.g. Mk6 mortar) — the gunner packs it alone, in place, now.
if (_baseBag isEqualTo "") exitWith {
    [_weapon, _gunner, _weaponBag, "", objNull, _curator] call FUNC(disassemblePack);
};

// Two-bag: find the man who takes the support bag before packing. Prefer the one
// who assembled it (tagged at assemble time), else the nearest bag-less groupmate
// on foot, skipping the group leader unless he is the only candidate.
private _assistant = objNull;
private _tagged = _weapon getVariable [QGVAR(assembleAssistant), objNull];
if (!isNull _tagged && {alive _tagged} && {isNull objectParent _tagged} && {group _tagged == group _gunner} && {backpack _tagged == ""}) then {
    _assistant = _tagged;
} else {
    private _cands = (units group _gunner) select {
        _x != _gunner && {alive _x} && {isNull objectParent _x} && {backpack _x == ""}
    };
    private _nonLeaders = _cands select { _x != leader group _gunner };
    if (_nonLeaders isNotEqualTo []) then { _cands = _nonLeaders; };
    _cands = _cands apply { [_x distance _gunner, _x] };
    _cands sort true;
    if (_cands isNotEqualTo []) then { _assistant = (_cands select 0) select 1; };
};

// No taker available — pack alone; the support bag drops on the ground.
if (isNull _assistant) exitWith {
    [_weapon, _gunner, _weaponBag, _baseBag, objNull, _curator] call FUNC(disassemblePack);
};

// Instant disassembly (CBA setting): skip walking the assistant — pack now
// (FUNC(disassemblePack) likewise skips the engine animation, and hands the
// support bag to the assistant regardless of his distance).
if (GETGVAR(instantAssemble,false)) exitWith {
    [_weapon, _gunner, _weaponBag, _baseBag, _assistant, _curator] call FUNC(disassemblePack);
};

// Walk the assistant to the weapon, then pack (FUNC(disassemblePack)). On timeout
// pack anyway, so a Zeus command always completes.
// Arrival radius 4 m; walk timeout 12 s scaled by distance. Pack on arrival, or
// in place on the assistant's death/timeout, so a Zeus command always completes.
[
    [_assistant], getPosATL _weapon, 4, 12 + (_assistant distance2D _weapon) * 0.5,
    LINKFUNC(disassemblePack),
    LINKFUNC(disassemblePack),
    [_weapon, _gunner, _weaponBag, _baseBag, _assistant, _curator],
    true,
    _curator,
    "Assistant couldn't reach - packing in place"
] call EFUNC(common,approach);
