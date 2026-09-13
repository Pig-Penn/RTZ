#include "\x\rtz\addons\repair\script_component.hpp"
/*
 * Disposable integration regressions; run on the server in the test mission:
 * [] execVM "rtz_job_lifecycle.sqf"
 * Results go to the RPT and system chat. Requires loaded RTZ and CBA.
 * This exercises real PFHs and objects; it is not a multiplayer simulation.
 */
if (!isServer) exitWith {systemChat "Run RTZ job regressions on the server."};

private _failures = [];
private _check = {
    params ["_condition", "_name"];
    if (!_condition) then {_failures pushBack _name};
};
private _owner = "Land_HelipadEmpty_F" createVehicle [0, 0, 0];
private _deleted = [0, 0, true];
[
    _owner, "regressionDelete", 30, 0.1,
    {params ["_args"]; _args set [0, (_args select 0) + 1]; true},
    _deleted,
    {params ["_args", "_full"]; _args set [1, (_args select 1) + 1]; _args set [2, _full]}
] call EFUNC(common,progressJob);
deleteVehicle _owner;
sleep 1;
[(_deleted select 1) == 1 && {!(_deleted select 2)}, "Deleted owner must cancel and clean up once"] call _check;

_owner = "Land_HelipadEmpty_F" createVehicle [0, 0, 0];
private _old = [0];
private _new = [0, false];
[_owner, "regressionReplace", 30, 0.1, {true}, _old, {
    params ["_args"]; _args set [0, (_args select 0) + 1];
}] call EFUNC(common,progressJob);
[_owner, "regressionReplace", 1, 0.1, {true}, _new, {
    params ["_args", "_full"]; _args set [0, (_args select 0) + 1]; _args set [1, _full];
}] call EFUNC(common,progressJob);
sleep 2;
[(_old select 0) == 0, "Superseded job must not clean up its replacement"] call _check;
[(_new select 0) == 1 && {_new select 1}, "Replacement must complete once"] call _check;
deleteVehicle _owner;

private _group = createGroup [west, true];
private _unit = _group createUnit ["B_engineer_F", [50, 50, 0], [], 0, "NONE"];
_unit setVariable [QEGVAR(common,approachOrder), 2, true];
_unit setVariable ["lambs_danger_forceMove", true];
[_unit, 1] call FUNC(finishRepair);
[_unit getVariable ["lambs_danger_forceMove", false], "Stale release must preserve the new errand"] call _check;
[_unit, 2] call FUNC(finishRepair);
[!(_unit getVariable ["lambs_danger_forceMove", false]), "Current release must clear the errand"] call _check;

private _vehicle = "B_Quadbike_01_F" createVehicle [52, 50, 0];
_vehicle setDamage 0.5;
_unit setVariable ["lambs_danger_forceMove", true];
[_unit, _vehicle, 2] call FUNC(repairJob);
// Join a second worker: deletion cleanup must retain later arrivals too.
private _second = _group createUnit ["B_engineer_F", [50, 51, 0], [], 0, "NONE"];
_second setVariable [QEGVAR(common,approachOrder), 1, true];
_second setVariable ["lambs_danger_forceMove", true];
[_second, _vehicle, 1] call FUNC(repairJob);
deleteVehicle _vehicle;
sleep 2;
[!(_unit getVariable ["lambs_danger_forceMove", false]), "Deleting repair target must release first worker"] call _check;
[!(_second getVariable ["lambs_danger_forceMove", false]), "Deleting repair target must release later arrival"] call _check;

_unit setVariable ["lambs_danger_forceMove", true];
[_unit, objNull, 2] call FUNC(repairJob);
sleep 1;
[!(_unit getVariable ["lambs_danger_forceMove", false]), "Rejected arrival must release its worker"] call _check;
deleteVehicle _unit;
deleteVehicle _second;
deleteGroup _group;

private _message = format ["RTZ job lifecycle: %1 failures: %2", count _failures, _failures];
diag_log _message;
systemChat _message;
