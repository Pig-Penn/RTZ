#include "script_component.hpp"
/*
 * Author: Maxim
 * SERVER ONLY. The vehicle half of the selection data stream: tracks which
 * vehicles each curator has selected (fed by FUNC(selectionInfo)'s poll over
 * QGVAR(selVehicles)), gathers a packet per vehicle (FUNC(gatherVehicleInfo))
 * and pushes them to that curator's client over QGVAR(selVehicleData).
 *
 * Mirrors FUNC(selectionGather)'s infantry loop: unscheduled PFH at the live
 * GVAR(gatherInterval) setting, diff-gated per player, zero work while nobody
 * has vehicles selected, stale subscribers pruned in passing.
 *
 * Loading: called unconditionally from XEH_postInit under isServer, NOT from the
 *   CBA_settingsInitialized gate — see FUNC(selectionGather) for why gating
 *   server code on an isGlobal 0 setting is a trap. No scheduled ops.
 *
 * Arguments:
 * None
 *
 * Return Value:
 * None
 *
 * Example:
 * call rtz_selection_fnc_vehicleGather
 *
 * Public: No
 */

if (!isServer) exitWith {};

// playerNetId → selected vehicle netIds. Empty selections REMOVE the entry
// (the client clears its own display on deselect), so the gather loop below
// idles at a single count check while no curator has vehicles selected.
GVAR(selVehiclesByPlayer) = createHashMap;

// playerNetId → packet array last actually SENT (same diff-gate as the infantry
// gather): the gather still runs every tick, but an identical result — parked
// vehicles, nothing hit — skips the network hop.
GVAR(selVehLastSent) = createHashMap;

[QGVAR(selVehicles), {
    params ["_player", "_sel"];
    if (isNull _player) exitWith {};
    private _pk = netId _player;
    if (_sel isEqualTo []) exitWith {
        GVAR(selVehiclesByPlayer) deleteAt _pk;
        GVAR(selVehLastSent)      deleteAt _pk;
    };
    GVAR(selVehiclesByPlayer) set [_pk, _sel];
    // A fresh report always gets a full send — the client may have cleared its
    // own map since the last one, so the diff baseline must not linger.
    GVAR(selVehLastSent) deleteAt _pk;
}] call CBA_fnc_addEventHandler;

// ── Gather loop ──────────────────────────────────────────────────────────────
[{
    params ["_state"];
    _state params ["_nextRun"];
    if (CBA_missionTime < _nextRun) exitWith {};
    _state set [0, CBA_missionTime + ((GETGVAR(gatherInterval,0.3)) max GATHER_TICK)];
    if (count GVAR(selVehiclesByPlayer) == 0) exitWith {};
    private _stale = [];
    {
        // HashMap forEach: _x is the KEY (player netId), _y the VALUE (selection).
        // ALIAS THE KEY. The inner forEach below overwrites _x with a vehicle
        // netId, and _x stays clobbered after it ends (docs/Gotchas.md §2). Using
        // _x for the diff-gate after the inner loop — as this loop used to —
        // looked up and stored under the last VEHICLE's netId: the gate could
        // never match, so every subscriber got a full packet push on every single
        // tick, and GVAR(selVehLastSent) grew one permanent entry per vehicle
        // netId ever selected while the prune below only ever removed player keys.
        private _pk     = _x;
        private _player = objectFromNetId _pk;
        if (isNull _player || { isNull (getAssignedCuratorLogic _player) }) then {
            _stale pushBack _pk;
            continue;
        };
        // Virtual Zeus (VirtualMan_F) is the game master, not a PvP officer —
        // exempt from the own-side filter (mirrors the infantry gather).
        private _anySide  = _player isKindOf "VirtualMan_F";
        private _cSide    = side _player;
        private _vpackets = [];
        // Re-capped even though the poll already capped: this list arrives over a
        // client-fired server event, so the bound is not the client's to promise.
        {
            private _v = objectFromNetId _x;
            if (isNull _v || { !alive _v }) then { continue };
            if (!_anySide && { !(VEH_SIDE_OK(_v,_cSide)) }) then { continue };
            _vpackets pushBack ([_v] call FUNC(gatherVehicleInfo));
        } forEach (_y select [0, SEL_MAX_VEHICLES]);
        // Diff-gate: unchanged since the last send → skip the network hop.
        // objNull default so a missing entry never compares equal to any array.
        if (_vpackets isEqualTo (GVAR(selVehLastSent) getOrDefault [_pk, objNull])) then { continue };
        GVAR(selVehLastSent) set [_pk, _vpackets];
        [QGVAR(selVehicleData), [_vpackets], _player] call CBA_fnc_targetEvent;
    } forEach GVAR(selVehiclesByPlayer);
    {
        GVAR(selVehiclesByPlayer) deleteAt _x;
        GVAR(selVehLastSent)      deleteAt _x;
    } forEach _stale;
}, GATHER_TICK, [0]] call CBA_fnc_addPerFrameHandler;
