#include "script_component.hpp"
/*
 * Author: Maxim
 * SERVER handler for QGVAR(applyAura) (registered in XEH_postInit). Maintains
 * GVAR(auras) — officerNetId -> aura radius — the registry FUNC(monitorAuras)
 * sweeps. Unlike editing areas there is no engine object behind an aura, so
 * this is pure bookkeeping: the monitor derives the zone live from the
 * officer's position each pass, which is how the aura follows him.
 *
 * The registry is server-side because an aura is a world effect, not
 * per-curator state: any curator may toggle any officer's aura and it must
 * survive its creator disconnecting. Each officer also carries a public
 * GVAR(auraActive) flag so every client's context modifier and the
 * editing-area guard in FUNC(setArea) read the state without a round-trip.
 *
 * Mutual exclusion: an officer with an editing area — ANY curator's, checked
 * against RTZ_officerZoneRadiusMap — cannot take an aura, mirroring the aura
 * guard in FUNC(setArea). Removal is bookkeeping only: groups the aura was
 * holding are released by the next FUNC(monitorAuras) pass (≤ AURA_INTERVAL
 * seconds), so removal never needs to know who was inside.
 *
 * Curator feedback is sent from here via QGVAR(auraMsg) to the requester —
 * only the server knows whether a request actually applied.
 *
 * Arguments:
 * 0: Mode — "add" or "remove" <STRING>
 * 1: Officers <ARRAY>
 * 2: Requesting curator player, receives feedback messages (optional) <OBJECT>
 *
 * Return Value:
 * None
 *
 * Example:
 * ["add", [_officer], _player] call rtz_officer_fnc_applyAura
 *
 * Public: No
 */

params ["_mode", "_officers", ["_requester", objNull]];

private _applied = 0;
private _areaBlocked = false;

{
    private _key = netId _x;

    if (_mode isEqualTo "add") then {
        if (!alive _x || {_key in GVAR(auras)}) then {continue};

        if (_key in RTZ_officerZoneRadiusMap) then {
            _areaBlocked = true;
            continue;
        };

        GVAR(auras) set [_key, GVAR(auraRadius)];
        SETPVAR(_x,GVAR(auraActive),true);
        _applied = _applied + 1;
    } else {
        if (isNil {GVAR(auras) deleteAt _key}) then {continue};

        SETPVAR(_x,GVAR(auraActive),nil);
        _applied = _applied + 1;
    };
} forEach _officers;

if (isNull _requester) exitWith {};

private _msg = if (_mode isEqualTo "add") then {
    if (_applied > 0) then {
        [LSTRING(MsgAuraAdded), round GVAR(auraRadius)]
    } else {
        [[LSTRING(MsgAuraUnavailable)], [LSTRING(MsgAuraBlockedArea)]] select _areaBlocked
    };
} else {
    [LSTRING(MsgAuraRemoved)]
};

[QGVAR(auraMsg), [_msg], _requester] call CBA_fnc_targetEvent;
