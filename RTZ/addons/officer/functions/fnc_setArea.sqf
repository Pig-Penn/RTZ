#include "script_component.hpp"
/*
 * Author: Maxim
 * Add/remove primitive for a single officer's curator editing area, operating
 * on the local player's curator module and the per-client tracking map
 * GVAR(areas). Idempotent — adding twice or removing a non-existent area is a
 * no-op. Because a curator with any editing area can only edit inside its
 * areas, this is what confines a Zeus to building near their own officers.
 *
 * The area is planted where the officer stands at this moment and never moves
 * again — it does NOT follow him (see FUNC(monitorAreas) for why). Only the
 * allocated area id is tracked per officer, since nothing re-reads the centre
 * or radius afterwards. A successful removal arms GVAR(cooldowns) for
 * COOLDOWN_DURATION seconds (see FUNC(isOnCooldown)), so an area cannot be
 * instantly re-planted — moving your editing rights is meant to cost that
 * wait. Gated on GVAR(cooldownEnable); when off, removal is instant.
 *
 * Locality: call on any curator machine. The BIS curator logic is local to the
 * SERVER and add/removeCuratorEditingArea require the curator to be local, so
 * the engine calls are dispatched there via QGVAR(applyArea) (FUNC(applyArea)),
 * which also registers each area server-side so orphans can be wiped after a
 * rejoin.
 *
 * Arguments:
 * 0: Officer <OBJECT>
 * 1: Enable — true adds an area, false removes it <BOOLEAN>
 *
 * Return Value:
 * Success — false if a requested add/remove did not happen, e.g. the officer
 * is in combat/careless or there was nothing to remove <BOOLEAN>
 *
 * Example:
 * [_officer, true] call rtz_officer_fnc_setArea
 *
 * Public: No
 */

params ["_officer", "_enable"];

private _curator = getAssignedCuratorLogic player;
if (isNull _curator) exitWith {false};

private _key = netId _officer;

if (_enable) then {
    if (_key in GVAR(areas)) exitWith {false};            // already has an area
    if (!alive _officer) exitWith {false};                // never anchor to a corpse
    if ([_officer] call FUNC(isOnCooldown) > 0) exitWith {false}; // just torn down, not re-plantable yet
    if (behaviour _officer in ["COMBAT", "CARELESS"]) exitWith {false}; // don't hand out editing rights while the officer is in a firefight or not paying attention
    if (GETVAR(_officer,GVAR(auraActive),false)) exitWith {false}; // command aura active — the two officer zones are mutually exclusive (see FUNC(applyAura))

    private _areaId = GVAR(nextAreaId);
    GVAR(nextAreaId) = _areaId + 1;

    private _radius = GVAR(areaRadius);
    private _pos = getPosWorld _officer;

    [QGVAR(applyArea), ["add", _curator, [_areaId, _pos, _radius, _key]]] call CBA_fnc_serverEvent;
    GVAR(areas) set [_key, [_areaId]];
    true
} else {
    private _entry = GVAR(areas) deleteAt _key;
    if (isNil "_entry") exitWith {false};

    [QGVAR(applyArea), ["remove", _curator, [_entry select 0]]] call CBA_fnc_serverEvent;
    if (GVAR(cooldownEnable)) then {
        GVAR(cooldowns) set [_key, CBA_missionTime + COOLDOWN_DURATION];
    };
    true
};
