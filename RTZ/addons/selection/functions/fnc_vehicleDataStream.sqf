#include "script_component.hpp"
/*
 * rtz_fnc_vehicleDataStream
 *
 * Shared vehicle-selection data stream consumed by both rtz_fnc_vehicleOverlay
 * (bottom-right stat cards) and rtz_fnc_vehicleTags (floating head tags) — split
 * out so either display can run without the other being enabled.
 *
 * CLIENT: receives the per-vehicle packets pushed by the server gather below
 * and keeps GVAR(selVehicleData) (netId → packet) current; GVAR(vehDataDirty)
 * flags rtz_fnc_vehicleOverlay that a fresh push arrived and its cards need a
 * relayout.
 * SERVER: mirrors rtz_fnc_selectionInfo's infantry gather loop — tracks which
 * vehicles each curator has selected (GVAR(selVehiclesByPlayer), fed by the
 * selection poll's QGVAR(selVehicles) event) and pushes a gathered packet per
 * vehicle over QGVAR(selVehicleData) on an unscheduled ~3 Hz PFH.
 *
 * Requirements: CBA_A3; LAMBS optional (task/tactic fields blank without it).
 * Loading: called from XEH_postInit after CBA_settingsInitialized whenever
 *   GVAR(enableVehicleOverlay) or GVAR(enableVehicleTags) is set — ordered
 *   before FUNC(vehicleOverlay) and FUNC(vehicleTags) so their own
 *   QGVAR(selVehicleData) handlers see this system's hashmap already filled.
 *   Contains no scheduled ops, so it is `call`ed, not `spawn`ed.
 */

// ─────────────────────────────────────────────────────────────────────────────
// CLIENT — vehicle packet receipt
// ─────────────────────────────────────────────────────────────────────────────
if (hasInterface) then {
    GVAR(selVehicleData) = createHashMap;
    GVAR(vehDataDirty)   = true;

    [QGVAR(selVehicleData), {
        params ["_packets"];
        private _m = createHashMap;
        { _m set [_x select 0, _x] } forEach _packets;
        GVAR(selVehicleData) = _m;
        GVAR(vehDataDirty)   = true;
    }] call CBA_fnc_addEventHandler;
};

if (!isServer) exitWith {};

// ─────────────────────────────────────────────────────────────────────────────
// SERVER — configuration
// ─────────────────────────────────────────────────────────────────────────────
// Defines rather than privates: they are read inside the gather PFH's stored code,
// which runs long after this registration scope is gone (same as rtz_fnc_selectionInfo).

#define GATHER_INTERVAL 0.3   // Seconds between vehicle gathers (~3 Hz).
#define OWN_ONLY true         // Only read out a curator's OWN-side vehicles.

// ─────────────────────────────────────────────────────────────────────────────
// SERVER — state
// ─────────────────────────────────────────────────────────────────────────────

// playerNetId → selected vehicle netIds. Empty selections REMOVE the entry
// (the client clears its own display on deselect), so the gather loop below
// idles at a single count check while no curator has vehicles selected.
GVAR(selVehiclesByPlayer) = createHashMap;

[QGVAR(selVehicles), {
    params ["_player", "_sel"];
    if (isNull _player) exitWith {};
    if (_sel isEqualTo []) exitWith { GVAR(selVehiclesByPlayer) deleteAt (netId _player) };
    GVAR(selVehiclesByPlayer) set [netId _player, _sel];
}] call CBA_fnc_addEventHandler;

// ─────────────────────────────────────────────────────────────────────────────
// SERVER — per-vehicle gather
// ─────────────────────────────────────────────────────────────────────────────
// Vehicle-global fields (speed, fuel, damage, crew) are valid on any machine.
// Crew AI fields (LAMBS task/tactic, unit state) are locality-bound so they are
// read only under an `if (local _ec)` guard; when the crew is on a Headless
// Client those lines are omitted rather than shown as misleading zeros.
//
// Packet layout (index → field) — kept in lockstep with the client card render:
//   0 netId  1 sideNum  2 displayName  3 speedKmh  4 fuelPct  5 healthPct
//   6 crewCnt  7 ecNetId  8 flags[]  9 unitState  10 task  11 tactic
//   12 magazineCnt  13 seatCnt  14 flyHeight (commanded AI fly-in height, m; -1 unset)
//   15 selAmmo (rounds in the crew's currently selected weapon; -1 unset/unknown)

private _fnc_gatherVehicle = {
    params ["_veh"];
    private _sideNum = SIDE_NUM(side group _veh);
    private _ec    = effectiveCommander _veh;
    private _ecNet = if (isNull _ec) then { "" } else { netId _ec };
    private _flags = [];
    if (fuel _veh < 0.15)   then { _flags pushBack "LOW FUEL" };
    if (damage _veh > 0.60) then { _flags pushBack "DAMAGED" };

    private _state  = "";
    private _task   = "";
    private _tactic = "";
    if (!isNull _ec && { local _ec }) then {
        _state  = getUnitState _ec;
        _task   = _ec getVariable ["lambs_main_currentTask", ""];
        _tactic = (group _ec) getVariable ["lambs_main_currentTactic", ""];
    };

    // Rounds in the crew's currently selected weapon (index 15). Weapon
    // selection is locality-bound, so read it only where the vehicle is local
    // (Zeus AI vehicles are server-local); -1 elsewhere or with no armed gunner,
    // so the tag drops the field rather than showing a stale/zero count.
    private _selAmmo = -1;
    if (local _veh) then {
        private _shooter = gunner _veh;
        if (isNull _shooter) then { _shooter = _ec };
        if (!isNull _shooter) then {
            private _turret = _veh unitTurret _shooter;
            private _muzzle = _veh currentWeaponTurret _turret;
            if (_muzzle != "") then {
                _selAmmo = (weaponState [_veh, _turret, _muzzle]) param [4, -1];
            };
        };
    };

    [
        netId _veh, _sideNum,
        (_veh call EFUNC(common,classInfo)) select 0,
        round (abs speed _veh),
        round (fuel _veh * 100),
        round ((1 - damage _veh) * 100),
        count crew _veh,
        _ecNet, _flags,
        _state, _task, _tactic,
        count (magazinesAllTurrets _veh),
        count (fullCrew [_veh, "", true]),  // total positions incl. cargo/FFV
        // Commanded AI fly-in height set by the fly-height keybinds (broadcast
        // public by rtz_fnc_adjustHeliHeight); -1 for a vehicle never adjusted.
        _veh getVariable [QEGVAR(common,flyHeight), -1],
        _selAmmo
    ]
};

// ─────────────────────────────────────────────────────────────────────────────
// SERVER — gather loop
// ─────────────────────────────────────────────────────────────────────────────
// A CBA PFH rather than a spawned while/sleep thread (mirrors rtz_fnc_selectionInfo's
// infantry gather): unscheduled, so the cadence never degrades under scheduler load.
// Zero work while nobody has vehicles selected; entries whose player disconnected or
// dropped curator are pruned in passing (deleted AFTER the forEach — never mutate a
// HashMap mid-iteration). The gather closure travels in the PFH args so it stays in
// scope when the stored code runs.

[{
    params ["_args"];
    _args params ["_fnc_gatherVehicle"];
    if (count GVAR(selVehiclesByPlayer) == 0) exitWith {};
    private _stale = [];
    {
        // HashMap forEach: _x is the KEY (player netId), _y the VALUE (selection).
        private _player = objectFromNetId _x;
        if (isNull _player || { isNull (getAssignedCuratorLogic _player) }) then {
            _stale pushBack _x;
            continue;
        };
        private _cSide    = side _player;
        // Virtual Zeus (VirtualMan_F) is the game master, not a PvP officer —
        // exempt from OWN_ONLY (mirrors the infantry gather's exemption).
        private _anySide  = _player isKindOf "VirtualMan_F";
        private _vpackets = [];
        {
            private _v = objectFromNetId _x;
            if (isNull _v || { !alive _v }) then { continue };
            if (OWN_ONLY && { !_anySide } && { side (group _v) != _cSide }) then { continue };
            _vpackets pushBack ([_v] call _fnc_gatherVehicle);
        } forEach (_y select [0, SEL_MAX_VEHICLES]);
        [QGVAR(selVehicleData), [_vpackets], _player] call CBA_fnc_targetEvent;
    } forEach GVAR(selVehiclesByPlayer);
    { GVAR(selVehiclesByPlayer) deleteAt _x } forEach _stale;
}, GATHER_INTERVAL, [_fnc_gatherVehicle]] call CBA_fnc_addPerFrameHandler;
