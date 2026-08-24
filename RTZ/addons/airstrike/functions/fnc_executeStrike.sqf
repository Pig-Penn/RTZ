#include "script_component.hpp"
/*
 * Author: Maxim
 * Receives an airstrike order on the machine that owns the aircraft, captures what
 * the strike is about to override, and registers the record the tick will drive.
 *
 * Arguments:
 * 0: Aircraft <OBJECT>
 * 1: Aim point ASL <ARRAY>
 * 2: Bearing, direction of flight in degrees <NUMBER>
 * 3: Weapon as [weapon, turretPath, type] <ARRAY>
 *
 * Return Value:
 * None
 *
 * Example:
 * [_vehicle, _aim, 270, ["Bomb_04_Plane_CAS_01_F", [-1], 3]] call rtz_airstrike_fnc_executeStrike
 *
 * Public: No
 */

params ["_vehicle", "_aim", "_bearing", "_weaponData"];

// The setting is GLOBAL, so this machine holds its own copy and is entitled to refuse.
// The condition on the curator's client is a UI gate, not an authorization: a curator
// whose client has the feature on must not be able to fly an aircraft on a machine
// where it is off.
if (!GVAR(enabled)) exitWith {};

if (!local _vehicle) exitWith {};
if (!alive _vehicle) exitWith {};

private _driver = driver _vehicle;
if (isNull _driver || {!alive _driver} || {isPlayer _driver}) exitWith {};

// A re-order REPLACES, it never stacks. Without this a curator who re-tasks the same
// jet three times gets three records driving one hull, each fighting the others for
// its velocity — the same shape as the per-order watch EFUNC(attack,addWaypoint)
// used to stack, since deleted.
private _existing = GVAR(active) findIf {(_x select STRIKE_PLANE) isEqualTo _vehicle};

if (_existing != -1) then {
    [GVAR(active) select _existing] call FUNC(endStrike);
    GVAR(active) deleteAt _existing;
};

// Captured BEFORE anything is forced, so teardown restores the state the aircraft
// actually had rather than the state this strike put it in. Restoring blanket-enabled
// AI would switch on features some other RTZ order had deliberately disabled.
private _restore = [
    _driver checkAIFeature "MOVE",
    _driver checkAIFeature "TARGET",
    _driver checkAIFeature "AUTOTARGET",
    behaviour _driver,
    combatMode (group _driver)
];

_driver disableAI "MOVE";
_driver disableAI "TARGET";
_driver disableAI "AUTOTARGET";
_driver setBehaviour "CARELESS";
(group _driver) setCombatMode "BLUE";

private _start = _aim getPos [RUN_IN_DISTANCE, _bearing + 180];
_start set [2, (getTerrainHeightASL _start) + RUN_IN_ALTITUDE];

// Derived ONCE, here, rather than re-read from config on every tick.
private _cruise = ((getNumber (configOf _vehicle >> "maxSpeed") * CRUISE_COEF) / 3.6) max CRUISE_MIN;

private _now = CBA_missionTime;

GVAR(active) pushBack [
    _vehicle, _driver, _aim, _bearing, _weaponData,
    PHASE_INGRESS, _start, _restore, [], objNull,
    0, 0, _now + INGRESS_TIMEOUT, _now + STRIKE_TIMEOUT, 0,
    _cruise, 0, 0, false
];

// Created by the first strike, destroyed by the last. Between strikes the handler
// does not exist, so idle cost is nothing rather than merely small.
if (GVAR(pfh) == -1) then {
    GVAR(lastTick) = _now;
    GVAR(pfh) = [LINKFUNC(strikeTick), 0] call CBA_fnc_addPerFrameHandler;
};
