#include "script_component.hpp"
/*
 * Author: Maxim
 * Per-client lifecycle loop for officer editing areas. Runs a single low-rate
 * CBA perFrameHandler (MONITOR_INTERVAL) that does two cheap things:
 *
 * 1. Curator lifecycle — when the local player's curator changes (assigned,
 *    lost, or module swapped), every RTZ area is cleared from BOTH modules:
 *    the one lost (merely forgetting them is not enough — the module survives
 *    unassignment and can be handed back later) and the one gained. The
 *    gained-module wipe is the JIP/rejoin fix: the per-client tracking map
 *    dies with the session, so a rejoined (or newly assigned) curator would
 *    otherwise inherit orphaned areas that confine them with no way to remove
 *    them. The server-side registry in FUNC(applyArea) knows which IDs to
 *    remove.
 * 2. Pruning — areas whose officer has died or been deleted are removed, so
 *    an area never lingers after its anchor is gone. An area is also torn
 *    down the moment its officer enters COMBAT or CARELESS behaviour (mirrors
 *    the entry block in FUNC(setArea): a Zeus should not keep editing rights
 *    over a position once his anchor is in a firefight or not paying
 *    attention), arming the same COOLDOWN_DURATION so it cannot be instantly
 *    re-planted once behaviour normalizes.
 *
 * Areas do NOT follow their officer. An area is anchored to the position the
 * officer stood on when it was planted and stays there for its whole life; the
 * officer is the area's ANCHOR (his death or combat state ends it, above), not
 * a handle that drags it around. A Zeus who wants editing rights somewhere
 * else removes the area and re-plants it — that is what COOLDOWN_DURATION
 * prices. This is deliberate: a zone that trailed a walking officer would hand
 * a Zeus continuously moving editing rights over ground he never committed an
 * officer to. Do not re-add a re-centring pass here.
 *
 * Areas are only ever added on demand by FUNC(setArea) via the context-menu
 * toggle; there is deliberately no auto-add on officer placement.
 *
 * Arguments:
 * None
 *
 * Return Value:
 * None
 *
 * Example:
 * call rtz_officer_fnc_monitorAreas
 *
 * Public: No
 */

if (!hasInterface) exitWith {};

// PFH args carry the last curator seen, so we only react when it actually changes
[{
    (_this select 0) params ["_lastCurator"];
    private _curator = getAssignedCuratorLogic player;

    if (_curator isNotEqualTo _lastCurator) then {
        {
            if (!isNull _x) then {
                [QGVAR(applyArea), ["clear", _x]] call CBA_fnc_serverEvent;
            };
        } forEach [_lastCurator, _curator];

        GVAR(areas) = createHashMap;
        (_this select 0) set [0, _curator];
    };

    if (isNull _curator || {count GVAR(areas) == 0}) exitWith {};

    // Prune areas whose anchor is gone or is no longer in a state that earns
    // editing rights. Deletions are collected and applied after the loop —
    // GVAR(areas) is being iterated.
    private _toDelete = [];
    private _combatRemoved = false;

    {
        _y params ["_areaId"];
        private _officer = objectFromNetId _x;

        if (isNull _officer || {!alive _officer}) then {
            [QGVAR(applyArea), ["remove", _curator, [_areaId]]] call CBA_fnc_serverEvent;
            _toDelete pushBack _x;
        } else {
            if (behaviour _officer in ["COMBAT", "CARELESS"]) then {
                [QGVAR(applyArea), ["remove", _curator, [_areaId]]] call CBA_fnc_serverEvent;
                GVAR(cooldowns) set [_x, CBA_missionTime + COOLDOWN_DURATION];
                _toDelete pushBack _x;
                _combatRemoved = true;
            };
        };
    } forEach GVAR(areas);

    {GVAR(areas) deleteAt _x} forEach _toDelete;

    // One message per pass, not per officer: a firefight that catches several
    // anchors at once tears down several areas in the same pass, and the
    // curator does not need to be told that once per area
    if (_combatRemoved) then {
        [LSTRING(MsgAreaCombatRemoved)] call zen_common_fnc_showMessage;
    };
}, MONITOR_INTERVAL, [objNull]] call CBA_fnc_addPerFrameHandler;
