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

// Assembly/packing completion is delayed by engine animation and deterministic
// fallbacks.  An old completion must release only crew whose token it still owns,
// and must never erase a newer operation's machine-local context.
_unit setVariable [QEGVAR(common,approachOrder), 10, true];
_second setVariable [QEGVAR(common,approachOrder), 20, true];
_unit setVariable ["lambs_danger_forceMove", true];
_second setVariable ["lambs_danger_forceMove", true];
private _newBuildTokens = [[_unit, 10], [_second, 20]];
_unit setVariable [QEGVAR(assemble,buildCtx), ["pending", _second, objNull, -1, -1, _newBuildTokens]];
[objNull, _unit, _second, [[_unit, 9], [_second, 19]]] call EFUNC(assemble,finishBuild);
[
    _unit getVariable ["lambs_danger_forceMove", false]
        && {_second getVariable ["lambs_danger_forceMove", false]},
    "Stale build completion must preserve newer crew errands"
] call _check;
[
    (_unit getVariable [QEGVAR(assemble,buildCtx), []]) isNotEqualTo [],
    "Stale build completion must preserve newer build context"
] call _check;

[objNull, _unit, _second, [[_unit, 10], [_second, 19]]] call EFUNC(assemble,finishBuild);
[
    !(_unit getVariable ["lambs_danger_forceMove", false])
        && {_second getVariable ["lambs_danger_forceMove", false]},
    "Build completion must release only crew it still owns"
] call _check;

_unit setVariable ["lambs_danger_forceMove", true];
private _newPackTokens = [[_unit, 10], [_second, 20]];
_unit setVariable [QEGVAR(assemble,packCtx), ["pending", _second, objNull, -1, objNull, _newPackTokens]];
[_unit, _second, objNull, [[_unit, 9], [_second, 19]]] call EFUNC(assemble,finishPack);
[
    _unit getVariable ["lambs_danger_forceMove", false]
        && {_second getVariable ["lambs_danger_forceMove", false]},
    "Stale pack completion must preserve newer crew errands"
] call _check;
[
    (_unit getVariable [QEGVAR(assemble,packCtx), []]) isNotEqualTo [],
    "Stale pack completion must preserve newer pack context"
] call _check;

deleteVehicle _unit;
deleteVehicle _second;
deleteGroup _group;

// rtz_dig sinks a cell ~15 times over its dig rather than once at the end, so the
// ordering of those writes is now load-bearing. EFUNC(dig,sinkCell) is pure server-side
// arithmetic over the heightmap and needs no digger to exercise — but it writes the
// REAL terrain, so the one vertex it touches is put back before this script ends.
getTerrainInfo params ["", "", "_cellSize"];

private _vx = 0;
private _vy = 0;
private _midpoint = _cellSize * round ((worldSize / 2) / _cellSize);

// Any inland vertex will do, so long as it is high enough that a full-depth dig cannot
// reach the waterline clamp and confuse the depth assertions below.
for "_i" from 1 to 400 do {
    private _x = _midpoint + _i * _cellSize;
    if ((getTerrainHeight [_x, _midpoint]) > 20) then {
        _vx = _x;
        _vy = _midpoint;
        break;
    };
};

if (_vx == 0) then {
    _failures pushBack "Dig regression found no land vertex to run on";
} else {
    private _original = getTerrainHeight [_vx, _vy];
    private _depth = EGVAR(dig,depth);
    // [CELL_CENTRE, CELL_VERTEX, CELL_SUNK] in a
    // [TRENCH_ID, HEIGHTS, CURATOR, PENDING, TOTAL, CELLS, DIGGERS] record.
    private _cell = [[_vx, _vy], [_vx, _vy, _original], 0];
    private _record = [-1, [], objNull, 1, 1, [_cell], []];

    [_record, _cell, 0.5] call EFUNC(dig,sinkCell);
    [
        abs ((getTerrainHeight [_vx, _vy]) - (_original - 0.5 * _depth)) < 0.01,
        "Half-dug cell must sit at half depth"
    ] call _check;

    // The one that matters: progress comes off the digger's machine, so an event can
    // arrive late. A stale fraction must not raise ground that is already dug.
    [_record, _cell, 0.25] call EFUNC(dig,sinkCell);
    [
        abs ((getTerrainHeight [_vx, _vy]) - (_original - 0.5 * _depth)) < 0.01,
        "Stale progress must not raise dug ground"
    ] call _check;

    [_record, _cell, 1] call EFUNC(dig,sinkCell);
    [
        abs ((getTerrainHeight [_vx, _vy]) - (_original - _depth)) < 0.01,
        "Finished cell must sit at full depth"
    ] call _check;

    [
        (count (_record select 1)) == 1,
        "Pristine height must be captured once however often a cell sinks"
    ] call _check;

    // The two end cells own no interior vertex and must deform nothing at all.
    private _endCell = [[_vx, _vy], [], 0];
    [_record, _endCell, 1] call EFUNC(dig,sinkCell);
    [
        abs ((getTerrainHeight [_vx, _vy]) - (_original - _depth)) < 0.01,
        "A cell with no vertex must not deform"
    ] call _check;

    // Waterline clamp. The vertex is real but its pristine height is faked to a metre,
    // so the arithmetic is tested without needing a shoreline to run the script on.
    private _shallow = [[_vx, _vy], [_vx, _vy, 1], 0];
    [[-2, [], objNull, 1, 1, [_shallow], []], _shallow, 1] call EFUNC(dig,sinkCell);
    [
        (getTerrainHeight [_vx, _vy]) > 0,
        "Waterline clamp must keep a shallow cell above sea level"
    ] call _check;

    setTerrainHeight [[[_vx, _vy, _original]], false];
    [
        abs ((getTerrainHeight [_vx, _vy]) - _original) < 0.01,
        "Dig regression must leave the heightmap as it found it"
    ] call _check;
};

private _message = format ["RTZ job lifecycle: %1 failures: %2", count _failures, _failures];
diag_log _message;
systemChat _message;
