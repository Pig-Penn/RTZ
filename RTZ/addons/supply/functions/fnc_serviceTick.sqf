#include "script_component.hpp"
/*
 * Author: Maxim
 * SERVER. One tick of a supply vehicle's service job — the EFUNC(common,progressJob)
 * step body for FUNC(serviceVehicles), lifted out of it so the loop is a named
 * function rather than a block nested three levels inside the order setup.
 *
 * Applies this tick's SHARE of each target's original deficit as a DELTA against
 * the vehicle's LIVE value; it never writes an absolute interpolated figure. That
 * distinction is the whole reason the snapshot is taken once: a vehicle shot up
 * mid-service keeps the new damage (the job just keeps chipping away at the
 * original deficit) instead of having it silently erased by the next write. The
 * share is measured against the clock by progressJob rather than counted per
 * tick, so a late or skipped tick catches up instead of short-changing the total.
 *
 * Only repair and fuel are worked off here. AMMO is not: there is no command that
 * reads a partial ammo ratio back, so it cannot be interpolated and is instead
 * topped up once, at the end, by FUNC(endService).
 *
 * useEffects false on the setDamage — this is scripted maintenance, not a hit, so
 * it must not fire the engine's damage/repair effect chain once a second for the
 * whole job.
 *
 * Arguments:
 * 0: Job Arguments <ARRAY> — [supply, canRepair, canRefuel, canRearm, work, radius, curator]
 * 1: Share Of The Job To Apply This Tick <NUMBER>
 *
 * Return Value:
 * Keep Going <BOOL>
 *
 * Example:
 * [_args, 0.05] call rtz_supply_fnc_serviceTick
 *
 * Public: No
 */

params ["_args", "_step"];
_args params ["_supply", "_canRepair", "_canRefuel", "", "_work", "_radius"];

if (!alive _supply) exitWith {false};

private _dropped = false;

{
    _x params ["_vehicle", "_startDamage", "_startFuel"];

    // Marked rather than deleted so the list is compacted at most once per tick
    // instead of being re-indexed mid-iteration.
    if (!alive _vehicle || {_vehicle distance _supply > _radius}) then {
        _x set [0, objNull];
        _dropped = true;
    } else {
        if (_canRepair && {_startDamage > 0}) then {
            _vehicle setDamage [((damage _vehicle) - (_startDamage * _step)) max 0, false];
        };

        // FUNC(applyFuel), not a bare setFuel: the argument is local and this
        // whole job runs on the server, so a vehicle owned by a headless client
        // or a player never saw the write. `fuel` reads correctly from anywhere,
        // so the delta is still computed here — only the write is routed.
        if (_canRefuel && {_startFuel < 1}) then {
            [_vehicle, ((fuel _vehicle) + ((1 - _startFuel) * _step)) min 1] call FUNC(applyFuel);
        };
    };
} forEach _work;

if (_dropped) then {
    _work = _work select {!isNull (_x select 0)};
    _args set [4, _work];

    // Keep the overlay contract in step, so a vehicle that drove off stops being
    // drawn as serviced. The record array is mutated in place — it is the same
    // array FUNC(gatherSupply) reads off the supply vehicle, so there is nothing
    // to write back.
    private _record = _supply getVariable [QGVAR(servicing), []];
    if (_record isNotEqualTo []) then {
        _record set [0, _work apply {_x select 0}];
    };
};

// Nothing left worth servicing — stop rather than idle out the duration
_work isNotEqualTo []
