#include "script_component.hpp"
/*
 * Author: Maxim
 * Clear the pack errand state after a static weapon is disassembled. Shared
 * by both pack paths in FUNC(packWeapon) - the real animation path (the
 * "WeaponDisassembled" engine event handler) and the deterministic fallback - so
 * they converge on one cleanup: release the crew (EFUNC(common,clearErrand)), nil the
 * pack ctx, and take the weapon back out of the group's LAMBS static list that
 * FUNC(finishBuild) put it into. Mirror of FUNC(finishBuild)'s tail.
 *
 * The QGVAR(packing) double-click guard needs no clear here: it lives on the weapon,
 * which the pack has just deleted.
 *
 * Arguments:
 * 0: Gunner <OBJECT>
 * 1: Assistant <OBJECT> - objNull for single bag weapons
 * 2: Packed Weapon <OBJECT> - objNull when the pack found nothing to remove
 * 3: Crew errand tokens, [[unit, token], ...] <ARRAY> (default: legacy unguarded cleanup)
 *
 * Return Value:
 * None
 *
 * Example:
 * [_gunner, _assistant, _weapon] call rtz_assemble_fnc_finishPack
 *
 * Public: No
 */

params ["_gunner", "_assistant", ["_weapon", objNull], ["_tokens", []]];

private _release = [];
{
    _x params ["_unit", "_token"];
    if (!isNull _unit && {_token >= 0} && {([_unit] call EFUNC(common,errandToken)) == _token}) then {
        _release pushBack _unit;
    };
} forEach _tokens;
if (_tokens isEqualTo []) then {_release = [_gunner, _assistant]};
[_release] call EFUNC(common,clearErrand);

if (isNull _gunner) exitWith {};

private _currentCtx = _gunner getVariable [QGVAR(packCtx), []];
if (_tokens isEqualTo [] || {(_currentCtx param [5, []]) isEqualTo _tokens}) then {
    _gunner setVariable [QGVAR(packCtx), nil];
};

// A deleted object goes null in the list rather than dropping out of it, so the null
// sweep also collects weapons LAMBS packed or that were destroyed since
private _group = group _gunner;
private _staticList = _group getVariable ["lambs_main_staticWeaponList", []];

if (_staticList isNotEqualTo []) then {
    _group setVariable ["lambs_main_staticWeaponList", _staticList select {!isNull _x && {_x != _weapon}}, true];
};
