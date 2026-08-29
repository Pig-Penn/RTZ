#include "script_component.hpp"
/*
 * Author: Maxim
 * How much work one target still needs from one supply vehicle, as a single
 * number. 0 means nothing to do.
 *
 * This is the component's only measure of "needs servicing", and it is used for
 * two jobs that used to be answered separately:
 *
 *  — FUNC(findTargets) keeps a target when the deficit is above zero, which is
 *    what puts the Resupply action on the menu.
 *  — FUNC(serviceTick) snapshots it once per target at the start and re-reads it
 *    every tick; `1 - (live / start)` is the progress the supply-lines overlay
 *    draws. Since the ENGINE now performs the services and reports nothing, an
 *    observed deficit closing is the only progress signal there is.
 *
 * The three services are summed rather than averaged so a vehicle that needs all
 * of them counts for more than one that needs a scratch buffed out — a truck
 * servicing a wrecked, dry, empty tank should not read as nearly finished the
 * moment the fuel tops up.
 *
 * Each service is thresholded BEFORE it is added, which is the part that is easy
 * to get wrong. Without it a vehicle one round below a full belt reports a
 * deficit of 0.005 forever: the engine will not top up a magazine that is
 * effectively full, the deficit never closes, and the order is offered again and
 * again while the monitor stalls out every time.
 *
 * Only services the supply vehicle actually offers are measured. That is not just
 * an optimisation — the ammo term walks every turret's magazines, and skipping it
 * for a repair truck keeps that walk off the ZEN context-menu path entirely.
 *
 * Arguments:
 * 0: Vehicle <OBJECT>
 * 1: Supply Capabilities <ARRAY> — [canRepair, canRefuel, canRearm]
 *
 * Return Value:
 * Deficit, 0 or more <NUMBER>
 *
 * Example:
 * [_vehicle, [true, false, true]] call rtz_supply_fnc_serviceDeficit
 *
 * Public: No
 */

params ["_target", "_capabilities"];
_capabilities params ["_canRepair", "_canRefuel", "_canRearm"];

private _deficit = 0;

if (_canRepair) then {
    private _damage = damage _target;
    if (_damage > REPAIR_THRESHOLD) then {
        _deficit = _deficit + _damage;
    };
};

if (_canRefuel) then {
    private _fuel = fuel _target;
    if (_fuel < FUEL_THRESHOLD) then {
        _deficit = _deficit + (1 - _fuel);
    };
};

if (_canRearm) then {
    private _ammo = [_target] call FUNC(ammoRatio);
    if (_ammo < AMMO_THRESHOLD) then {
        _deficit = _deficit + (1 - _ammo);
    };
};

_deficit
