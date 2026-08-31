#include "script_component.hpp"
/*
 * Author: Maxim
 * Server half: coalesces launches per target, resolves the curators that own the
 * threatened unit, and pushes one packet to each of them.
 *
 * EFUNC(common,curatorsOf) materialises every curator's editable set, so it is by
 * far the expensive part of this path. A launcher salvo at one vehicle would
 * otherwise pay for it once per missile while saying nothing the first warning did
 * not — hence the RECENT_WINDOW gate in front of it.
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

private _now = CBA_missionTime;
private _key = netId _target;

// A literal 0 as the default is free to evaluate eagerly; the getOrDefault caveat
// only bites when the default is an expression.
if ((GVAR(recent) getOrDefault [_key, 0]) > _now) exitWith {};

GVAR(recent) set [_key, _now + RECENT_WINDOW];

// Bound the window map. Expired entries first — that alone clears it in every
// realistic case — and a whole flush behind it so the map can never grow past the
// cap even if every entry is somehow still live.
if (count GVAR(recent) > RECENT_CAP) then {
    private _dead = [];

    {
        if (_y <= _now) then {
            _dead pushBack _x;
        };
    } forEach GVAR(recent);

    {
        GVAR(recent) deleteAt _x;
    } forEach _dead;

    if (count GVAR(recent) > RECENT_CAP) then {
        GVAR(recent) = createHashMap;
    };
};

private _curators = [_target] call EFUNC(common,curatorsOf);
if (_curators isEqualTo []) exitWith {};

private _payload = [_missile, _target, _side];

{
    // isPlayer, not isNull: a departed Zeus leaves a non-null server-local body
    // behind, and on a listen server that body's owner is the host — so an isNull
    // test would render a departed curator's warnings on the host's screen.
    private _player = getAssignedCuratorUnit _x;
    if (!isPlayer _player) then {continue};

    [QGVAR(track), _payload, _player] call CBA_fnc_targetEvent;
} forEach _curators;
