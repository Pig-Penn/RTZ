#include "script_component.hpp"
/*
 * Author: Maxim
 * SERVER. Completion pass for a supply vehicle's service job — the
 * EFUNC(common,progressJob) end hook for FUNC(serviceVehicles).
 *
 * This addon had no end hook at all, which left three things broken. It now
 * closes all three:
 *
 *  — THE SNAP. setDamage does not store the figure it is given verbatim: the
 *    engine redistributes it across hit points and `damage` reads back an
 *    aggregate. The per-tick delta chain therefore drifts, and a job that has
 *    applied a vehicle's entire deficit still leaves it a hair above zero —
 *    permanently, because the next order sees a vehicle that "still needs
 *    repair" and repeats the same near-miss. Damage inside REPAIR_THRESHOLD and
 *    fuel inside FUEL_THRESHOLD are snapped to their end stops. Only inside those
 *    windows: a vehicle genuinely shot up mid-service must keep its new damage,
 *    which is the entire point of the delta model FUNC(serviceTick) uses.
 *
 *  — THE REARM. setVehicleAmmo takes a LOCAL argument, so the server calling it
 *    on a vehicle owned by a headless client or a player is a silent no-op. It is
 *    routed to the vehicle's own machine instead. Ammo is applied here rather
 *    than per tick because nothing can read a partial ammo ratio back, so there
 *    is no deficit to interpolate — it is one write at the end, not a ramp.
 *
 *  — THE REPORT. The order was the only one in the mod that told the curator
 *    nothing; FUNC(orderResupply) now toasts on despatch and this closes the loop
 *    on completion. The stringtable KEY is sent, not the localised text, so each
 *    client renders it in its own language.
 *
 * The snap, the rearm and the report all run only on a job that reached FULL
 * progress. A job that stopped early — the supply truck died, or every target
 * drove out of range — has not finished anything.
 *
 * Releasing the targets, in contrast, happens either way and comes first: a job
 * that died two seconds into a thirty second order would otherwise leave its
 * targets locked against every other supply vehicle for the remaining half
 * minute. Only claims still held by THIS vehicle are dropped, so releasing can
 * never take a target away from a job that has since claimed it. The expiry the
 * claims carry (see CLAIM_GRACE) stays as the backstop for the one path that
 * does not reach here at all — being superseded by a repeat order, which
 * re-claims what it needs anyway.
 *
 * Arguments:
 * 0: Job Arguments <ARRAY> — [supply, canRepair, canRefuel, canRearm, work, radius, curator]
 * 1: Ran To Full Progress <BOOL>
 *
 * Return Value:
 * None
 *
 * Example:
 * [_args, true] call rtz_supply_fnc_endService
 *
 * Public: No
 */

params ["_args", "_full"];
_args params ["_supply", "_canRepair", "_canRefuel", "_canRearm", "_work", "", "_curator"];

// Drops the supply-lines overlay for this vehicle however the job ended
if (!isNull _supply) then {
    _supply setVariable [QGVAR(servicing), nil];
};

{
    private _vehicle = _x select 0;
    if (isNull _vehicle) then { continue };

    if (((_vehicle getVariable [QGVAR(claim), []]) param [0, objNull]) isEqualTo _supply) then {
        _vehicle setVariable [QGVAR(claim), nil];
    };
} forEach _work;

if (!_full) exitWith {};

private _serviced = 0;

{
    _x params ["_vehicle", "_startDamage", "_startFuel"];
    if (!alive _vehicle) then { continue };

    _serviced = _serviced + 1;

    if (_canRepair && {_startDamage > 0} && {damage _vehicle <= REPAIR_THRESHOLD}) then {
        _vehicle setDamage [0, false];
    };

    if (_canRefuel && {_startFuel < 1} && {fuel _vehicle >= FUEL_THRESHOLD}) then {
        _vehicle setFuel 1;
    };

    if (_canRearm) then {
        [QGVAR(rearm), [_vehicle], _vehicle] call CBA_fnc_targetEvent;
    };
} forEach _work;

if (_serviced == 0 || {isNull _curator}) exitWith {};

[QGVAR(report), [LSTRING(MsgResupplyComplete), _serviced], _curator] call CBA_fnc_targetEvent;
