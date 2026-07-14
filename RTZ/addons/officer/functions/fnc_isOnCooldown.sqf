#include "script_component.hpp"
/*
 * Author: Maxim
 * Seconds remaining before FUNC(setArea) will accept a new area for this
 * officer, 0 if he is ready. Armed by FUNC(setArea) on a successful removal
 * (COOLDOWN_DURATION) so a Zeus cannot instantly re-plant a zone he just tore
 * down. Lazily forgets an expired entry so GVAR(cooldowns) does not grow for
 * the lifetime of the mission.
 *
 * Arguments:
 * 0: Officer <OBJECT>
 *
 * Return Value:
 * Seconds Remaining, 0 if ready <NUMBER>
 *
 * Example:
 * [_officer] call rtz_officer_fnc_isOnCooldown
 *
 * Public: No
 */

params ["_officer"];

private _key = netId _officer;
private _readyAt = GVAR(cooldowns) getOrDefault [_key, -1];
if (_readyAt < 0) exitWith {0};

private _remaining = _readyAt - CBA_missionTime;
if (_remaining <= 0) exitWith {
    GVAR(cooldowns) deleteAt _key;
    0
};

_remaining
