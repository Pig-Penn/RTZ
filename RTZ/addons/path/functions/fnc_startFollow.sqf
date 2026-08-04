#include "script_component.hpp"
/*
 * Author: Maxim
 * Puts a committed path into execution. Runs where the unit is local — the only
 * machine an AI order has any effect on — reached by the targeted event
 * FUNC(commitPaths) sends.
 *
 * doStop first, always, whatever the kind. It is not optional for either
 * executor: setDriveOnPath will not drive a vehicle whose AI still has a
 * formLeader, and an infantry doMove chain issued to a unit still in formation
 * is pulled back out of its path by the group leader within seconds.
 *
 * Two executors, not four:
 *
 *  - Land vehicles get setDriveOnPath, and the engine drives. There is no
 *    ongoing work at all — the record exists only so the path can be noticed
 *    finishing, restarted for a patrol lap, and cleaned up.
 *
 *  - Everything else — men, aircraft and boats alike — gets a doMove chain
 *    advanced by FUNC(followTick), differing only in how close counts as
 *    arrived and, for aircraft, in the cruise height each leg is flown at. The
 *    AI keeps MOVE and ANIM throughout, so a man walks with his own animations,
 *    paths around what he meets and still reacts to contact, and a helicopter
 *    flies with the real flight model rather than being dragged along a line.
 *
 * That second executor is where this departs from Wargame most. setDriveOnPath
 * has no effect on Air or Ship — it needs an AI steering component neither has —
 * so Wargame writes its own flight model: a 0.0005-second handler per aircraft
 * doing setVelocity and setVectorDirAndUp with hand-rolled acceleration, started
 * from a spawned waitUntil. Handing the same path to the AI as a chain of move
 * orders costs nothing per aircraft, keeps real physics, landing and collision,
 * and follows a traced flight plan closely enough that the difference is not
 * visible from a curator camera. The same reasoning covers infantry: Wargame
 * uses disableAI "MOVE"/"ANIM" with per-frame setVectorDir steering and forced
 * animation looping to get exact footsteps, at the cost of a unit that cannot
 * take cover.
 *
 * Re-tasking a unit that is already following drops its old record WITHOUT the
 * teardown's restore: the unit is about to be stopped again, so handing it back
 * to its group in between would only make it start walking home first.
 *
 * Arguments:
 * 0: Unit to order — a man on foot, or a vehicle's driver <OBJECT>
 * 1: Hull that moves <OBJECT>
 * 2: Path legs, ASL <ARRAY>
 * 3: Path kind, one of KIND_* <NUMBER>
 * 4: Cycle the path instead of stopping at the end <BOOL>
 *
 * Return Value:
 * None
 *
 * Example:
 * [_unit, _hull, _legs, KIND_INFANTRY, false] call rtz_path_fnc_startFollow
 *
 * Public: No
 */

params ["_unit", "_hull", "_points", "_kind", "_patrol"];

// State goes stale across a network hop, so nothing here trusts what the client
// believed when it sent this
if (isNull _unit || {!local _unit}) exitWith {};
if (_points isEqualTo []) exitWith {};
if ([_hull] call FUNC(pathKind) == KIND_NONE) exitWith {};

private _active = GVAR(active);

private _existing = _active findIf {(_x select FOLLOW_UNIT) isEqualTo _unit};
if (_existing != -1) then {
    _active deleteAt _existing;
};

doStop _unit;

// Land vehicles need their path in the shape setDriveOnPath takes: ground-plane
// x/y with a zero height and a per-point speed in m/s. Built once and kept, so a
// patrol lap re-issues rather than rebuilds.
private _drive = [];

if (_kind == KIND_LAND) then {
    private _top = getNumber (configOf _hull >> "maxSpeed");
    if (_top <= 0) then {_top = 40};
    _top = _top min GETGVAR(maxVehicleSpeed,60);

    // The curator's own speed setting still has the last word on pace
    if ((speedMode (group _unit)) isEqualTo "LIMITED") then {_top = _top * 0.5};

    private _speed = _top / 3.6;

    {
        _drive pushBack [_x select 0, _x select 1, 0, _speed];
    } forEach _points;

    // The opening leg sits almost on top of the vehicle, and steering toward
    // something it is already standing on makes it stall before it starts.
    // Wargame drops this point too, for the same reason.
    if (count _drive >= 2) then {
        _drive deleteAt 0;
    };
};

// Resolved here, once, because it is not a property of the KIND: a plane and a
// helicopter are both KIND_AIR and could not be less alike about what "reached"
// means. A plane cannot stop, hover, or turn tightly — held to a helicopter's
// radius it orbits the point forever instead of flying on.
private _arrival = switch (_kind) do {
    case KIND_LAND: {ARRIVAL_LAND};
    case KIND_BOAT: {ARRIVAL_BOAT};
    case KIND_AIR: {[ARRIVAL_HELI, ARRIVAL_PLANE] select (_hull isKindOf "Plane")};
    default {ARRIVAL_INFANTRY};
};

private _now = CBA_missionTime;

_active pushBack [
    _unit,
    _hull,
    _points,
    0,
    _kind,
    _patrol,
    _now + (GETGVAR(timeout,20) * 60),
    _now,
    0,
    _drive,
    _arrival
];

// Created by the first path, destroyed by the last (FUNC(followTick)) — the
// idle cost of this component on a machine with nothing following is nothing
if (GVAR(pfh) == -1) then {
    GVAR(pfh) = [LINKFUNC(followTick), TICK_INTERVAL] call CBA_fnc_addPerFrameHandler;
};

if (_kind == KIND_LAND) exitWith {
    _hull setDriveOnPath _drive;
};

// Everything that is not a land vehicle walks, flies or sails the path on the
// same doMove chain — the executor differs only in how close counts as arrived,
// and, for aircraft, in the cruise height each leg is flown at.
private _first = ASLToAGL (_points select 0);

if (_kind == KIND_AIR) then {
    _hull flyInHeight (_first select 2);
};

_unit doMove _first;

