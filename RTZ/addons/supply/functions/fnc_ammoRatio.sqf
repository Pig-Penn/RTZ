#include "script_component.hpp"
/*
 * Author: Maxim
 * How well armed a vehicle is, 0..1. 1 means nothing to give it.
 *
 * There is no engine command that reads an ammo ratio back, so it is computed as
 * the mean of every turret magazine's rounds against its configured size, through
 * EFUNC(common,magazineCapacity) — which caches per magazine class, because the
 * same handful of classes recur across every vehicle and EFUNC(control,needsReload)
 * asks the identical question.
 *
 * Hulls only. Vanilla ammo trucks carry a vehicle rearm pool (getAmmoCargo) and no
 * infantry magazines, so there is nothing for one to hand a rifleman — resupplying
 * men would need a transport with actual magazines in its inventory, which is a
 * different feature with a different source test. This component services
 * vehicles.
 *
 * This replaced the old FUNC(needsAmmo), which returned a plain BOOL — any turret
 * magazine one round short counted as needing a rearm. A ratio is needed now
 * because FUNC(serviceTick) watches the deficit close to measure progress, and it
 * is also strictly better behaved: a single round fired from a 200-round belt no
 * longer keeps the Resupply action offered forever (see AMMO_THRESHOLD).
 *
 * Arguments:
 * 0: Vehicle <OBJECT>
 *
 * Return Value:
 * Ammo Level, 0..1 <NUMBER>
 *
 * Example:
 * [_vehicle] call rtz_supply_fnc_ammoRatio
 *
 * Public: No
 */

params ["_target"];

private _magazines = magazinesAllTurrets _target;

// An unarmed hull is fully armed by definition — a fuel truck must never be
// reported as needing a rearm, or an ammo truck would offer to service it.
if (_magazines isEqualTo []) exitWith {1};

private _total = 0;

{
    _x params ["_magazine", "", "_rounds"];

    // max 1 on the capacity: a magazine class with no `count` entry would
    // otherwise divide by zero and poison the mean for the whole vehicle.
    _total = _total + (_rounds / (([_magazine] call EFUNC(common,magazineCapacity)) max 1));
} forEach _magazines;

(_total / (count _magazines)) min 1
