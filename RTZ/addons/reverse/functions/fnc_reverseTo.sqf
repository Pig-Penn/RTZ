#include "script_component.hpp"
/*
 * Author: Maxim
 * Makes a vehicle reverse in a straight line to a destination. The maneuver
 * ends on arrival, when the vehicle gets stuck, when the driver is lost, or
 * after the timeout setting. Must be executed where the vehicle is local.
 *
 * Arguments:
 * 0: Vehicle <OBJECT>
 * 1: Destination AGL <ARRAY>
 *
 * Return Value:
 * None
 *
 * Example:
 * [_vehicle, _pos] call rtz_reverse_fnc_reverseTo
 *
 * Public: No
 */

params ["_vehicle", "_destination"];

// Supersede any pending order so only the newest one is executed
private _order = (_vehicle getVariable [QGVAR(order), 0]) + 1;
_vehicle setVariable [QGVAR(order), _order];

// Keep formation movement from fighting the reverse commands
doStop driver _vehicle;

[{
    params ["_args", "_handle"];
    _args params ["_vehicle", "_destination", "_order", "_endTime"];

    if (!alive _vehicle || {_vehicle getVariable [QGVAR(order), 0] != _order}) exitWith {
        [_handle] call CBA_fnc_removePerFrameHandler;
    };

    private _driver = driver _vehicle;

    // Destination reached or overshot (no longer behind the vehicle)
    private _toDestination = _destination vectorDiff getPosATL _vehicle;
    _toDestination set [2, 0];

    private _arrived = _vehicle distance2D _destination <= ARRIVAL_DISTANCE
        || {_toDestination vectorDotProduct vectorDir _vehicle >= 0};

    if (abs speed _vehicle > STUCK_SPEED) then {
        _args set [4, CBA_missionTime];
    };

    if (
        _arrived
        || {isNull _driver} || {!alive _driver} || {isPlayer _driver}
        || {!canMove _vehicle}
        || {CBA_missionTime > _endTime}
        || {CBA_missionTime - (_args select 4) > STUCK_TIME}
    ) exitWith {
        [_handle] call CBA_fnc_removePerFrameHandler;

        _vehicle sendSimpleCommand "STOP";

        // Release the driver back to formation movement
        if (!isNull _driver && {alive _driver} && {!isPlayer _driver}) then {
            _driver doFollow leader _driver;
        };
    };

    _vehicle sendSimpleCommand "BACKWARD";
}, COMMAND_INTERVAL, [_vehicle, _destination, _order, CBA_missionTime + GVAR(timeout), CBA_missionTime]] call CBA_fnc_addPerFrameHandler;
