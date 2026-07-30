#include "script_component.hpp"
/*
 * Author: Maxim
 * SERVER ONLY. Reads one vehicle's state into a compact packet for the overlay
 * cards (FUNC(vehicleOverlay)) and the vehicle head tags (FUNC(vehicleTags)).
 *
 * Vehicle-global fields (speed, fuel, damage, crew) are valid on any machine.
 * Crew AI fields (LAMBS task/tactic) are locality-bound so they are read only
 * under an `if (local _ec)` guard; when the crew is on a Headless Client those
 * lines are omitted rather than shown as misleading zeros.
 *
 * Packet layout (index → field) — kept in lockstep with FUNC(buildVtagEntry),
 * FUNC(vehicleCardBody) and FUNC(vehicleCardLayout):
 *   0 netId  1 sideNum  2 displayName  3 speedKmh  4 fuelPct  5 healthPct
 *   6 crewCnt  7 ecNetId  8 flags[]  9 task  10 tactic  11 magazineCnt
 *   12 seatCnt  13 flyHeight (commanded AI fly-in height, m; -1 unset)
 *   14 selAmmo (rounds in the crew's currently selected weapon; -1 unset/unknown)
 *
 * flags[] carries the FLAG_* wire tokens from script_component.hpp, never display
 * text — the client resolves each to a localized label through GVAR(tagLabels).
 *
 * Arguments:
 * 0: Vehicle to read <OBJECT>
 *
 * Return Value:
 * Packet <ARRAY>
 *
 * Example:
 * [_vehicle] call rtz_selection_fnc_gatherVehicleInfo
 *
 * Public: No
 */

params ["_veh"];

private _ec    = effectiveCommander _veh;
// Not `select (!isNull _ec)` — that would still evaluate netId on objNull.
private _ecNet = if (isNull _ec) then { "" } else { netId _ec };

private _flags = [];
if (fuel _veh < 0.15)   then { _flags pushBack FLAG_LOW_FUEL };
if (damage _veh > 0.60) then { _flags pushBack FLAG_DAMAGED };

private _task   = "";
private _tactic = "";
if (!isNull _ec && { local _ec }) then {
    _task   = _ec getVariable ["lambs_main_currentTask", ""];
    _tactic = (group _ec) getVariable ["lambs_main_currentTactic", ""];
};

// Rounds in the crew's currently selected weapon. Weapon selection is
// locality-bound, so read it only where the vehicle is local (Zeus AI vehicles
// are server-local); -1 elsewhere or with no armed gunner, so the tag drops the
// field rather than showing a stale/zero count.
private _selAmmo = -1;
if (local _veh) then {
    private _shooter = gunner _veh;
    if (isNull _shooter) then { _shooter = _ec };
    if (!isNull _shooter) then {
        private _turret = _veh unitTurret _shooter;
        private _muzzle = _veh currentWeaponTurret _turret;
        if (_muzzle != "") then {
            private _wstate = weaponState [_veh, _turret, _muzzle];
            // Magazine-less "weapons" (e.g. a car horn) report a muzzle with no
            // magazine (index 3) — skip those rather than showing a false AMMO 0.
            if ((_wstate param [3, ""]) != "") then {
                _selAmmo = _wstate param [4, -1];
            };
        };
    };
};

[
    netId _veh,
    SIDE_NUM(side group _veh),
    // Mission-long per-class cache in rtz_common — no config read per tick.
    (_veh call EFUNC(common,classInfo)) select 0,
    round (abs speed _veh),
    round (fuel _veh * 100),
    round ((1 - damage _veh) * 100),
    count crew _veh,
    _ecNet, _flags,
    _task, _tactic,
    count (magazinesAllTurrets _veh),
    // Total positions incl. cargo/FFV — class-static, so counted once per
    // vehicle class (fullCrew allocates the whole position list every call).
    GVAR(seatCntCache) getOrDefaultCall [typeOf _veh, { count (fullCrew [_veh, "", true]) }, true],
    // Commanded AI fly-in height set by the fly-height keybinds (broadcast
    // public by rtz_common's adjustHeliHeight event handler); -1 for a
    // vehicle never adjusted.
    _veh getVariable [QEGVAR(common,flyHeight), -1],
    _selAmmo
]
