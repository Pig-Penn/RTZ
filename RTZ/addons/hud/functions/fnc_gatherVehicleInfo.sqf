#include "script_component.hpp"
/*
 * Author: Maxim
 * SERVER ONLY. Reads one vehicle's state into a compact packet for the vehicle
 * head tags (FUNC(drawVehicleTags)).
 *
 * Vehicle-global fields (speed, fuel, damage, crew) are valid on any machine.
 * Crew AI fields (LAMBS task/tactic, and the engine `fleeing` state behind the
 * FLEEING flag) are locality-bound so they are read only under an
 * `if (local _ec)` guard; when the crew is on a Headless Client those lines are
 * omitted rather than shown as misleading zeros.
 *
 * Packet layout (index → field) — kept in lockstep with FUNC(buildVtagEntry),
 * its only reader:
 *   0 netId  1 displayName  2 speedKmh  3 fuelPct  4 healthPct  5 crewCnt
 *   6 ecNetId  7 flags[]  8 task  9 tactic  10 seatCnt
 *   11 flyHeight (commanded AI fly-in height, m; -1 unset)
 *   12 selAmmo (rounds in the crew's currently selected weapon; -1 unset/unknown)
 *   13 ammoBars ([[rounds, capacity], ...], one per armed turret; [] unknown)
 *
 * A sideNum and a magazine count used to ride along at indices 1 and 11. Both
 * were read only by the bottom-right stat cards, which are gone; the magazine
 * count in particular was a magazinesAllTurrets allocation per vehicle per tick
 * paid for a field nothing rendered.
 *
 * flags[] carries the FLAG_* wire tokens from script_component.hpp, never display
 * text — the client resolves each to a localized label through GVAR(tagLabels).
 *
 * Arguments:
 * 0: Vehicle to read <OBJECT>
 * 1: Its netId, already resolved by the stream engine <STRING>
 *
 * Return Value:
 * Packet <ARRAY>
 *
 * Example:
 * [_vehicle, netId _vehicle] call rtz_hud_fnc_gatherVehicleInfo
 *
 * Public: No
 */

params ["_veh", "_netId"];

private _ec    = effectiveCommander _veh;
// Not `select (!isNull _ec)` — that would still evaluate netId on objNull.
private _ecNet = if (isNull _ec) then { "" } else { netId _ec };

// Locality of the crew, not of the hull: the AI reads below answer only where
// the commander is, and a vehicle can be local to a machine its crew is not.
private _ecLocal = !isNull _ec && { local _ec };

private _flags = [];
// Routed crew — the vehicle counterpart of the infantry FLEEING flag, read
// under the same locality guard FUNC(gatherUnitInfo) reads it under, because
// `fleeing` only answers where the unit is. Pushed FIRST so it leads the joined
// status the tag builds out of these flags: a crew that has broken and is
// driving away is the one thing on this list worth reading before the hull's
// own condition.
if (_ecLocal && { fleeing _ec }) then { _flags pushBack FLAG_FLEEING };
if (fuel _veh < 0.15)   then { _flags pushBack FLAG_LOW_FUEL };
if (damage _veh > 0.60) then { _flags pushBack FLAG_DAMAGED };

private _task   = "";
private _tactic = "";
if (_ecLocal) then {
    _task   = _ec getVariable ["lambs_main_currentTask", ""];
    _tactic = (group _ec) getVariable ["lambs_main_currentTactic", ""];
};

// Rounds in the crew's currently selected weapon. Weapon selection is
// locality-bound, so read it only where the vehicle is local (Zeus AI vehicles
// are server-local); -1 elsewhere or with no armed gunner, so the tag drops the
// field rather than showing a stale/zero count.
private _selAmmo = -1;
// One [rounds, capacity] pair per armed turret, for the ammo gauges — the same
// reading as _selAmmo above but across every turret rather than only the one the
// crew has selected, and carrying the denominator a bar needs.
private _ammoBars = [];
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

    // Turret paths are class-static, so the list is built once per class — see
    // the note at GVAR(seatCntCache) below and in XEH_preInit. This field used to
    // have a magazinesAllTurrets ancestor that allocated per vehicle per tick
    // (see the packet-layout note above); what is left here is a handful of
    // cheap engine reads over a cached list.
    {
        private _muzzle = _veh currentWeaponTurret _x;
        if (_muzzle != "") then {
            private _wstate = weaponState [_veh, _x, _muzzle];
            private _mag = _wstate param [3, ""];
            // Same magazine-less skip as above — an unarmed turret contributes
            // no gauge rather than a permanently empty one.
            if (_mag != "") then {
                _ammoBars pushBack [_wstate param [4, -1], [_mag] call EFUNC(common,magazineCapacity)];
            };
        };
    } forEach (GVAR(turretsCache) getOrDefaultCall [typeOf _veh, { allTurrets _veh }, true]);
};

[
    _netId,
    // Mission-long per-class cache in rtz_common — no config read per tick.
    (_veh call EFUNC(common,classInfo)) select 0,
    round (abs speed _veh),
    round (fuel _veh * 100),
    round ((1 - damage _veh) * 100),
    count crew _veh,
    _ecNet, _flags,
    _task, _tactic,
    // Total positions incl. cargo/FFV — class-static, so counted once per
    // vehicle class (fullCrew allocates the whole position list every call).
    GVAR(seatCntCache) getOrDefaultCall [typeOf _veh, { count (fullCrew [_veh, "", true]) }, true],
    // Commanded AI fly-in height set by the fly-height keybinds (broadcast
    // public by rtz_orders' adjustHeliHeight event handler); -1 for a
    // vehicle never adjusted. This read is why rtz_orders is in this
    // component's requiredAddons — the order writes the variable, this
    // display reports it.
    _veh getVariable [QEGVAR(orders,flyHeight), -1],
    _selAmmo,
    _ammoBars
]
