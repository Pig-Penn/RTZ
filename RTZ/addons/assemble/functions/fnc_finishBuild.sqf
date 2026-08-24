#include "script_component.hpp"
/*
 * Author: Maxim
 * Finish a freshly raised static weapon. Shared by both build paths in
 * FUNC(buildWeapon) - the real animation path (the "WeaponAssembled" engine event
 * handler) and the deterministic fallback - so they converge on one post-build
 * routine: seat the gunner if he isn't already, face the weapon, align it to the
 * ground slope, tag the assistant for a later disassemble, register the weapon with
 * its owners (the gunner's group, LAMBS' own static list, and the curators who own
 * the gunner via EFUNC(common,grantCurators)), and clear the crew's errand state
 * (EFUNC(common,clearErrand)).
 *
 * A null weapon means the build aborted (the gunner went down): only the errand
 * state clear runs.
 *
 * Arguments:
 * 0: Assembled Weapon <OBJECT> - objNull clears the errand state and nothing else
 * 1: Gunner <OBJECT>
 * 2: Assistant <OBJECT> - objNull for single bag weapons
 *
 * Return Value:
 * None
 *
 * Example:
 * [_weapon, _gunner, _assistant] call rtz_assemble_fnc_finishBuild
 *
 * Public: No
 */

params ["_weapon", "_gunner", "_assistant"];

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

    // Align to the ground slope, after setDir - which would reset the vector.
    // surfaceNormal is fed ASL - it takes a PositionASL - so the weapon
    // lies flush on a rooftop or a bridge rather than on the terrain beneath it
    _weapon setVectorUp (surfaceNormal (getPosASL _weapon));

    // Remember the assistant so a later disassemble hands the support bag back to
    // the same man (read by FUNC(disassembleWeapon))
    SETPVAR(_weapon,GVAR(assistant),_assistant);

    if (!isNull _gunner) then {
        private _group = group _gunner;

        // The weapon is now the squad's own equipment: addVehicle lets the group's AI
        // treat it as theirs, and LAMBS reads the same static list its own deploy
        // writes (lambs_main_fnc_doGroupStaticDeploy) when it decides to redeploy or
        // pack up - so a weapon RTZ raised is one LAMBS knows about
        _group addVehicle _weapon;

        private _staticList = _group getVariable ["lambs_main_staticWeaponList", []];
        _staticList pushBackUnique _weapon;
        _group setVariable ["lambs_main_staticWeaponList", _staticList, true];
    };

    // A scripted createVehicle enters no curator's editable set, so grant it. The
    // grant needs the server, which EFUNC(common,grantCurators) hops to itself when
    // this errand ran on a headless client or a player's machine
    [_weapon, _gunner] call EFUNC(common,grantCurators);
};

[[_gunner, _assistant]] call EFUNC(common,clearErrand);

if (!isNull _gunner) then {
    // Public, like the claim FUNC(assembleWeapon) took: the context menu reads it
    // from the ordering curator's client, not from here
    SETPVAR(_gunner,GVAR(assembling),nil);
    _gunner setVariable [QGVAR(buildCtx), nil];
};
