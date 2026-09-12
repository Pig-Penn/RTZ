#include "script_component.hpp"
/*
 * Author: Maxim
 * Server half: coalesces launches per target, resolves the curators that own the
 * threatened unit, and pushes one packet to each of them.
 *
 * EFUNC(common,curatorsOf) materialises every curator's editable set, so it is by
 * far the expensive part of this path. A launcher salvo at one vehicle would
 * otherwise pay for it once per missile while saying nothing the first warning did
 * not — hence FUNC(claimWindow) in front of it.
 *
 * Arguments:
 * 0: Target <OBJECT>
 * 1: Projectile <OBJECT>
 * 2: Shooter's side <SIDE>
 *
 * Return Value:
 * None
 *
 * Example:
 * [_target, _missile, east] call rtz_missile_fnc_reportIncoming
 *
 * Public: No
 */

params ["_target", "_missile", "_side"];

if (!GVAR(enabled)) exitWith {};
if (isNull _target) exitWith {};

// Keyed on netId, because an Object is not a legal HashMap key (Gotchas §3). The
// window and its bound are FUNC(claimWindow), shared with the grenade half.
if !([GVAR(recent), netId _target, RECENT_WINDOW, CBA_missionTime] call FUNC(claimWindow)) exitWith {};

private _curators = [_target] call EFUNC(common,curatorsOf);
if (_curators isEqualTo []) exitWith {};

// KIND_MISSILE, and no fallback anchor: a missile that has not resolved on the
// receiving client falls back to the threatened unit, which travels in slot 1.
private _payload = [_missile, _target, _side, KIND_MISSILE];

{
    // isPlayer, not isNull: a departed Zeus leaves a non-null server-local body
    // behind, and on a listen server that body's owner is the host — so an isNull
    // test would render a departed curator's warnings on the host's screen.
    private _player = getAssignedCuratorUnit _x;
    if (!isPlayer _player) then {continue};

    [QGVAR(track), _payload, _player] call CBA_fnc_targetEvent;
} forEach _curators;
