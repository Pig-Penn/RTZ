#include "script_component.hpp"
/*
 * Author: Maxim
 * Finish a freshly raised static weapon. Shared by both build paths in
 * FUNC(buildWeapon) - the real animation path (the "WeaponAssembled" engine event
 * handler) and the deterministic fallback - so they converge on one post-build
 * routine: seat the gunner if he isn't already, face the weapon, align it to the
 * ground slope, tag the assistant for a later disassemble, hand the weapon to the
 * curators who own the gunner (FUNC(grantCurators)), and clear the crew's errand
 * state (FUNC(clearErrand)).
 *
 * A null weapon means the build aborted (the gunner went down): only the errand
 * state clear runs.
 *
 * Arguments:
 * 0: Assembled Weapon <OBJECT> - objNull clears the errand state and nothing else
 * 1: Gunner <OBJECT>
 * 2: Assistant <OBJECT> - objNull for single bag weapons
 * 3: Curator's Player <OBJECT> - unused, kept for call symmetry (default: objNull)
 *
 * Return Value:
 * None
 *
 * Example:
 * [_weapon, _gunner, _assistant] call rtz_assemble_fnc_finishBuild
 *
 * Public: No
 */

params ["_weapon", "_gunner", "_assistant", ["_curator", objNull]];

// The facing chosen in the placement preview rides in the ctx FUNC(buildWeapon)
// stashed on the gunner. -1 (no preview facing) falls back to auto-aiming at the
// nearest known enemy. Read before the clear below nils the ctx
private _ctx = if (isNull _gunner) then {[]} else {_gunner getVariable [QGVAR(buildCtx), []]};
private _direction = _ctx param [3, -1];

if (!isNull _weapon) then {
    // Seat the gunner. The engine's own assemble leaves the weapon empty (it only
    // fires the notification) while the fallback path already seated him - re-assert
    // so both paths converge on a manned weapon
    if (isNull (gunner _weapon) && {!isNull _gunner} && {alive _gunner}) then {
        _gunner assignAsGunner _weapon;
        _gunner moveInGunner _weapon;
    };

    // Honour the curator's chosen facing. With none (-1), face the nearest known
    // enemy if there is one, otherwise keep the current facing
    if (_direction >= 0) then {
        _weapon setDir _direction;
    } else {
        if (!isNull _gunner) then {
            private _enemy = _gunner findNearestEnemy _gunner;

            if (!isNull _enemy) then {
                _weapon setDir (_weapon getDir _enemy);
                _gunner doWatch _enemy;
            };
        };
    };

    // Align to the ground slope, after setDir - which would reset the vector
    _weapon setVectorUp (surfaceNormal (getPos _weapon));

    // Remember the assistant so a later disassemble hands the support bag back to
    // the same man (read by FUNC(disassembleWeapon))
    SETPVAR(_weapon,GVAR(assistant),_assistant);

    // A scripted createVehicle enters no curator's editable set, so grant it. The
    // grant needs the server, which FUNC(grantCurators) hops to itself when this
    // errand ran on a headless client or a player's machine
    [_weapon, _gunner] call FUNC(grantCurators);
};

[[_gunner, _assistant], [QGVAR(assembling), QGVAR(buildCtx)]] call FUNC(clearErrand);
