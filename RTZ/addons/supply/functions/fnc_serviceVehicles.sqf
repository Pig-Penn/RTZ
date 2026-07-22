#include "script_component.hpp"
/*
 * Author: Maxim
 * Runs one supply vehicle's order: damage and fuel are worked off over the
 * duration setting, ammo is topped up in one go at the end because there is no
 * way to read a partial ammo ratio back.
 *
 * The whole order is a single per-frame handler ticking at the
 * GVAR(serviceInterval) setting (read once at order start).
 * The starting damage and fuel are snapshotted here to size the job, but each
 * tick applies its SHARE of that deficit as a DELTA against the vehicle's live
 * value — it never writes an absolute interpolated figure. That distinction
 * matters under fire: a vehicle shot up mid-service keeps the new damage (the
 * service just keeps chipping away at the original deficit) instead of having it
 * silently erased by the next write. The share is taken from elapsed time rather
 * than a fixed per-tick step, so a skipped or late tick cannot drift the total.
 *
 * Targets are dropped once they die or drive out of range and the handler
 * removes itself as soon as the work is done or the list runs empty, so an order
 * costs nothing once it is finished. Must be executed on the server.
 *
 * Arguments:
 * 0: Supply Vehicle <OBJECT>
 * 1: Capabilities, as returned by FUNC(supplyCapabilities) <ARRAY>
 * 2: Vehicles To Service <ARRAY>
 *
 * Return Value:
 * None
 *
 * Example:
 * [_truck, [ARR_3(true,true,false)], _targets] call rtz_supply_fnc_serviceVehicles
 *
 * Public: No
 */

params ["_supply", "_capabilities", "_targets"];

if (!alive _supply || {_targets isEqualTo []}) exitWith {};

// Supersede any pending order on this vehicle so two loops never fight over the
// same targets with different snapshots
private _order = (_supply getVariable [QGVAR(order), 0]) + 1;
_supply setVariable [QGVAR(order), _order];

private _work = _targets apply {[_x, damage _x, fuel _x]};

// Progress is applied in clock-measured shares, so the tick interval only
// changes write granularity, never total service speed. Read once per order.
private _tick = (GETGVAR(serviceInterval,1)) max SERVICE_TICK_MIN;

[{
    params ["_args", "_handle"];
    _args params ["_supply", "_capabilities", "_work", "_order", "_radius", "_startTime", "_duration", "_lastProgress"];

    if (!alive _supply || {_supply getVariable [QGVAR(order), 0] != _order}) exitWith {
        [_handle] call CBA_fnc_removePerFrameHandler;
    };

    _capabilities params ["_canRepair", "_canRefuel", "_canRearm"];

    private _progress = ((CBA_missionTime - _startTime) / _duration) min 1;
    // Share of the total job to apply this tick, measured against the clock so a
    // late or skipped tick catches up instead of short-changing the total.
    private _step = _progress - _lastProgress;
    _args set [7, _progress];

    private _finished = _progress >= 1;
    private _dropped = false;

    {
        _x params ["_vehicle", "_startDamage", "_startFuel"];

        // Mark rather than delete so the list is compacted at most once per tick
        if (!alive _vehicle || {_vehicle distance2D _supply > _radius}) then {
            _x set [0, objNull];
            _dropped = true;
        } else {
            // The snapshot doubles as the needs-this-service test: a vehicle
            // pulled in for fuel alone never pays for a setDamage that would
            // write back the value it already has.
            // useEffects false — this is scripted maintenance, not a hit, so it
            // must not fire the damage/repair effect chain once a second.
            if (_canRepair && {_startDamage > 0}) then {
                _vehicle setDamage [((damage _vehicle) - (_startDamage * _step)) max 0, false];
            };

            if (_canRefuel && {_startFuel < 1}) then {
                _vehicle setFuel (((fuel _vehicle) + ((1 - _startFuel) * _step)) min 1);
            };

            if (_canRearm && _finished) then {
                _vehicle setVehicleAmmo 1;
            };
        };
    } forEach _work;

    if (_dropped) then {
        _work = _work select {!isNull (_x select 0)};
        _args set [2, _work];
    };

    if (_finished || {_work isEqualTo []}) then {
        [_handle] call CBA_fnc_removePerFrameHandler;
    };
}, _tick, [
    _supply,
    _capabilities,
    _work,
    _order,
    GVAR(serviceRadius),
    CBA_missionTime,
    GVAR(serviceDuration) max 1,
    0                               // _lastProgress — share of the job already applied
]] call CBA_fnc_addPerFrameHandler;
