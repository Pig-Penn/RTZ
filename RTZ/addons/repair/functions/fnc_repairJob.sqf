#include "script_component.hpp"
/*
 * Author: Maxim
 * SERVER handler body for QGVAR(join) (registered in XEH_postInit). Signs one
 * arriving engineer on to the repair job for a vehicle, starting that job if he is
 * the first to reach it.
 *
 * There is exactly ONE job per VEHICLE, never one per engineer. That is the whole
 * point: this addon used to give every ordered engineer his own loop with his own
 * starting-damage snapshot, and three engineers on one wreck spent the repair
 * overwriting each other's writes. Here the extra engineers instead divide the
 * work — each tick applies its share once, multiplied by the live worker count, so
 * N engineers finish in about GVAR(repairDuration) / N and joining or losing one
 * mid-job simply changes the rate from that moment on.
 *
 * Running on the server rather than where the engineer is local is deliberate:
 * setDamage has global effect and the server owns the AI vehicles this targets, so
 * an engineer local to a headless client still repairs a server-owned vehicle. It
 * also means the worker list is held on one machine and needs no syncing. This is
 * the same split rtz_supply uses for the same reason.
 *
 * The loop is EFUNC(common,progressJob), which supplies the clock-measured share
 * and the supersede guard. The share is applied as a DELTA against the vehicle's
 * live damage, so a vehicle shot up mid-repair keeps the new damage instead of
 * having it erased by the next write, and with useEffects false so the engine's
 * damage/repair effect chain does not fire twice a second for the whole job.
 *
 * Arguments:
 * 0: Unit <OBJECT>
 * 1: Vehicle <OBJECT>
 * 2: Errand Token <NUMBER> — the unit's EFUNC(common,errandToken) on arrival
 *
 * Return Value:
 * None
 *
 * Example:
 * [_unit, _vehicle, 3] call rtz_repair_fnc_repairJob
 *
 * Public: No
 */

params ["_unit", "_vehicle", ["_token", 0]];

if (!alive _unit || {isNull _vehicle} || {!alive _vehicle}) exitWith {};

private _workers = _vehicle getVariable [QGVAR(workers), []];

// Re-entry guard: a repeated order on an engineer already at the vehicle refreshes
// his token rather than signing him on twice and counting him double
private _index = _workers findIf {(_x select 0) isEqualTo _unit};

if (_index > -1) exitWith {
    (_workers select _index) set [1, _token];
};

_workers pushBack [_unit, _token];
_vehicle setVariable [QGVAR(workers), _workers];

// Somebody is already running the job for this vehicle — he has just been added to
// its crew and that is all this call had to do. Registration happens before this
// test, so two engineers arriving in the same frame cannot both start a job.
if (count _workers > 1) exitWith {};

[
    _vehicle,
    "repair",
    GVAR(repairDuration),
    REPAIR_TICK,
    {
        params ["_args", "_step"];
        _args params ["_vehicle", "_startDamage"];

        if (!alive _vehicle) exitWith {false};

        private _working = [];

        {
            _x params ["_unit", "_token"];

            switch (true) do {
                // Re-tasked by the curator: the new order owns him now, so drop him
                // WITHOUT releasing him — doing so would cancel that order
                case (([_unit] call EFUNC(common,errandToken)) != _token): {};

                // Dead, or knocked/blown clear of the vehicle he was working on
                case (!alive _unit || {_unit distance _vehicle > REPAIR_ABORT_DISTANCE}): {
                    [_unit] call FUNC(releaseWorker);
                };

                default {_working pushBack _x};
            };
        } forEach (_vehicle getVariable [QGVAR(workers), []]);

        _vehicle setVariable [QGVAR(workers), _working];

        // Nobody left working — stop rather than idle out the duration
        if (_working isEqualTo []) exitWith {false};

        // Each engineer works his own share of the job, so the crew divides the
        // duration between them. Applied as a delta against the live value, and
        // with useEffects false: this is scripted maintenance, not a hit
        _vehicle setDamage [((damage _vehicle) - (_startDamage * _step * (count _working))) max 0, false];

        damage _vehicle > 0
    },
    [_vehicle, damage _vehicle],
    {
        params ["_args"];
        _args params ["_vehicle"];

        // Fully repaired, or the job ran its duration out
        if (alive _vehicle && {damage _vehicle <= REPAIR_THRESHOLD}) then {
            _vehicle setDamage [0, false];
        };

        {
            [_x select 0] call FUNC(releaseWorker);
        } forEach (_vehicle getVariable [QGVAR(workers), []]);

        _vehicle setVariable [QGVAR(workers), nil];
    }
] call EFUNC(common,progressJob);
