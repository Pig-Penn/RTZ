#include "script_component.hpp"
/*
 * rtz_fnc_assembleWeaponFinalize
 *
 * SERVER: finish a freshly-raised static weapon. Shared by both build paths in
 * FUNC(assembleBuild) — the real-animation path (the "WeaponAssembled" engine EH)
 * and the deterministic fallback — so they converge on one post-build routine:
 * seat the gunner if he isn't already, face the weapon at the nearest known enemy,
 * align it to the ground slope, tag the assistant for a later disassemble, hand
 * the weapon to the curators who own the gunner (FUNC(grantCurators)), and clear
 * the crew's errand state via FUNC(clearErrandState).
 *
 * Parameters:
 *   0: Object — the assembled static weapon (objNull → abort: clear state only)
 *   1: Object — gunner
 *   2: Object — assistant (objNull for single-bag weapons)
 *   3: Object — ordering curator's player (unused here; kept for call symmetry)
 */

params ["_weapon", "_gunner", "_assistant", ["_curator", objNull]];

// Facing chosen in the placement preview, riding in the ctx stashed on the gunner
// by FUNC(assembleBuild). -1 (no preview facing) falls back to auto-aiming at the
// nearest known enemy. Read before the clear below nils the ctx.
private _ctx = if (isNull _gunner) then { [] } else { _gunner getVariable [QGVAR(assembleCtx), []] };
private _dir = _ctx param [3, -1];

private _fnc_clear = {
    params ["_gunner", "_assistant"];
    [[_gunner, _assistant], [QGVAR(assembling), QGVAR(assembleCtx)]] call FUNC(clearErrandState);
};

if (isNull _weapon) exitWith { [_gunner, _assistant] call _fnc_clear; };

// Seat the gunner. The engine's own assemble leaves the weapon empty (it only
// fires the notification); the fallback path already seated him — re-assert so
// both paths converge on a manned weapon.
if (isNull (gunner _weapon) && {!isNull _gunner} && {alive _gunner}) then {
    _gunner assignAsGunner _weapon;
    _gunner moveInGunner _weapon;
};

// Honour the curator's chosen facing from the placement preview. With none (-1),
// face the nearest known enemy if there is one; otherwise keep current facing.
if (_dir >= 0) then {
    _weapon setDir _dir;
} else {
    if (!isNull _gunner) then {
        private _enemy = _gunner findNearestEnemy _gunner;
        if (!isNull _enemy) then {
            _weapon setDir (_weapon getDir _enemy);
            _gunner doWatch _enemy;
        };
    };
};

// Align to the ground slope (after setDir — setDir would reset the vector).
_weapon setVectorUp (surfaceNormal (getPos _weapon));

// Remember the assistant so a later disassemble hands the support bag back to the
// same man (read by FUNC(disassembleWeaponApply) via QGVAR(assembleAssistant)).
SETPVAR(_weapon,GVAR(assembleAssistant),_assistant);

// A server-side createVehicle enters no curator's editable set — grant it.
[_weapon, _gunner] call FUNC(grantCurators);

[_gunner, _assistant] call _fnc_clear;
