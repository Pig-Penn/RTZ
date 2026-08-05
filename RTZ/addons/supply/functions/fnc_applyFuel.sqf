#include "script_component.hpp"
/*
 * Author: Maxim
 * Writes a fuel level to a vehicle wherever that vehicle happens to live.
 *
 * setFuel takes a LOCAL argument (effect global), exactly like setVehicleAmmo and
 * unlike setDamage. The service job runs entirely on the server — see
 * FUNC(serviceVehicles) — so every setFuel it issued against a vehicle owned by a
 * headless client or by a player was a silent no-op: no error, no log line, and
 * FUNC(endService) still counted the vehicle in its "resupply complete" toast. A
 * player-crewed truck parked at a depot would be repaired and rearmed but never
 * refuelled, which reads as an intermittent bug rather than a locality one.
 *
 * This is the QGVAR(rearm) pattern, generalised to the one place that still
 * needed it. The server writes DIRECTLY when it owns the vehicle — the
 * overwhelming majority of AI vehicles, and the case that runs every tick of
 * every job — so the common path costs no network traffic at all. Only a vehicle
 * that genuinely lives elsewhere pays for an event.
 *
 * Arguments:
 * 0: Vehicle <OBJECT>
 * 1: Fuel level, 0..1 <NUMBER>
 *
 * Return Value:
 * None
 *
 * Example:
 * [_vehicle, 1] call rtz_supply_fnc_applyFuel
 *
 * Public: No
 */

params ["_vehicle", "_fuel"];

if (isNull _vehicle || {!alive _vehicle}) exitWith {};

if (local _vehicle) exitWith {
    _vehicle setFuel _fuel;
};

[QGVAR(refuel), [_vehicle, _fuel], _vehicle] call CBA_fnc_targetEvent;
