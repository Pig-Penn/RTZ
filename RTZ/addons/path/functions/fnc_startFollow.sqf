#include "script_component.hpp"
/*
 * Author: Maxim
 * Puts a committed path into execution. Runs where the unit is local — the only
 * machine an AI order has any effect on — reached by the targeted event
 * FUNC(commitPaths) sends.
 *
 * doStop first, always, whatever the kind. It is not optional for any executor:
 * setDriveOnPath will not drive a vehicle whose AI still has a formLeader, and a
 * unit still in formation is pulled back out of its path by the group leader
 * within seconds however it is being moved.
 *
 * Three executors, chosen by kind and by setting:
 *
 *  - Land vehicles get setDriveOnPath, and the engine drives. There is no
 *    ongoing work at all — the record exists only so the path can be noticed
 *    finishing, restarted for a patrol lap, re-asserted if the engine drops it,
 *    and cleaned up.
 *
 *  - Men get the SCRIPTED move: MOVE and ANIM off, carried by a directional
 *    movement animation, hull turned by hand toward each leg
 *    (FUNC(setPuppet), FUNC(followTick)). This is what makes a drawn path get
 *    walked as drawn. What it costs is the unit's own reactions, and the two
 *    that matter are given back rather than written off — it breaks off to
 *    engage (FUNC(combatPause)) and it opens doors (FUNC(openDoors)).
 *
 *  - Aircraft and boats get the SCRIPTED flight model: attitude and velocity set
 *    directly, ten times a second, off the traced line (FUNC(flightTick)).
 *    setDriveOnPath does nothing for Air or Ship, and a doMove chain gives the
 *    AI a destination but no line — so a traced valley run comes out as a
 *    straight leg over the ridge, at whatever speed and height the AI prefers.
 *
 * Both scripted executors are refusable, and refusing them falls back to a
 * doMove chain — the AI's own navigation, with a limitSpeed ceiling off the
 * ground. That fallback keeps everything the scripted path gives up (cover,
 * collision avoidance, real autorotation and landing) at the price of a path
 * that is followed approximately rather than exactly. It is a mission-wide
 * setting because it has to be read where the unit is local and every machine
 * must agree.
 *
 * Nothing is ORDERED here. The record is built and the first order is issued by
 * the tick, at FOLLOW_START_AT — which is now for a fresh path and one settle
 * later for a re-task. Wargame waits between ending a scripted move and starting
 * the next and warns that not doing so "causes weird behaviour"; deferring to
 * the tick buys that without a spawn per order, and puts the launch on the one
 * pass that has already re-checked the unit is alive, local and in its seat.
 *
 * Re-tasking a unit that is already following drops its old record WITHOUT the
 * teardown's restore: the unit is about to be stopped again, so handing it back
 * to its group in between would only make it start walking home first. It does
 * still leave the scripted executor, because that one holds AI flags and event
 * handlers rather than an order and forgetting it would strand a puppet.
 *
 * Arguments:
 * 0: Unit to order — a man on foot, or a vehicle's driver <OBJECT>
 * 1: Hull that moves <OBJECT>
 * 2: Path legs, ASL <ARRAY>
 * 3: Path kind, one of KIND_* <NUMBER>
 * 4: Cycle the path instead of stopping at the end <BOOL>
 * 5: Facing spans as [[fromLeg, azimuth], ...] <ARRAY> (default: [])
 *
 * Return Value:
 * None
 *
 * Example:
 * [_unit, _hull, _legs, KIND_INFANTRY, false, []] call rtz_path_fnc_startFollow
 *
 * Public: No
 */

params ["_unit", "_hull", "_points", "_kind", "_patrol", ["_facing", []]];

// State goes stale across a network hop, so nothing here trusts what the client
// believed when it sent this
if (isNull _unit || {!local _unit}) exitWith {};
if (_points isEqualTo []) exitWith {};
if ([_hull] call FUNC(pathKind) == KIND_NONE) exitWith {};

// Read where the unit is LOCAL, which is the only machine the executors they
// gate have any effect on. The settings are global so this agrees with what the
// curator saw while drawing — and with the spacing FUNC(commitPaths) resampled
// at, which is the other thing they select.
private _executor = GETGVAR(infantryExecutor,EXEC_SCRIPTED);

private _scripted = switch (_kind) do {
    case KIND_INFANTRY: {_executor == EXEC_SCRIPTED};
    case KIND_AIR;
    case KIND_BOAT: {GETGVAR(scriptedFlight,true)};
    default {false};
};

// Facing spans name which of eight directional animations a puppet walks on, so
// a unit that is never going to be puppeted has no way to honour them. Dropped
// rather than checked per tick, so the branch costs nothing at all on the
// executor that cannot use it.
if (_executor == EXEC_AI) then {_facing = []};

private _active = GVAR(active);

private _existing = _active findIf {(_x select FOLLOW_UNIT) isEqualTo _unit};
private _retask = _existing != -1;

if (_retask) then {
    // Torn down rather than dropped: the outgoing record may have the unit
    // puppeted with its AI disabled and two handlers installed, and simply
    // forgetting it would leave nothing driving it. The rest of the teardown —
    // handing the unit back to its group — is deliberately NOT done, because the
    // unit is about to be stopped again and would only start walking home first.
    [_active select _existing, ""] call FUNC(setPuppet);
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

// Realigned before the vehicle is asked to drive. setDriveOnPath is issued to
// the HULL and obeyed through its effective commander, so a vehicle whose
// commander sits in another group — or is not aboard at all — can silently
// refuse the path. Wargame realigns at six separate call sites before driving,
// which is consistent enough to read as a prerequisite rather than a one-off.
//
// Guarded much harder than Wargame's, which passes `leader _driverGRP` — a man
// who need not be in the vehicle, and setting it wrong is worse than the stall
// it prevents. Only touched when the current answer is nobody who is actually
// aboard, and only ever set to the driver this path is addressed to.
if (_kind != KIND_INFANTRY) then {
    private _commander = effectiveCommander _hull;
    if (isNull _commander || {!(_commander in crew _hull)}) then {
        _hull setEffectiveCommander _unit;
    };
};

// Resolved here, once, because it is not a property of the KIND: a plane and a
// helicopter are both KIND_AIR and could not be less alike about what "reached"
// means. A plane cannot stop, hover, or turn tightly — held to a helicopter's
// radius it orbits the point forever instead of flying on.
private _isPlane = _hull isKindOf "Plane";

private _arrival = switch (_kind) do {
    case KIND_LAND: {ARRIVAL_LAND};
    case KIND_BOAT: {[ARRIVAL_BOAT, ARRIVAL_FLIGHT_BOAT] select _scripted};
    case KIND_AIR: {
        if (_scripted) then {
            [ARRIVAL_FLIGHT_HELI, ARRIVAL_FLIGHT_PLANE] select _isPlane
        } else {
            [ARRIVAL_HELI, ARRIVAL_PLANE] select _isPlane
        }
    };
    default {[ARRIVAL_INFANTRY, ARRIVAL_PUPPET] select _scripted};
};

// ── Flight profile and cruise ───────────────────────────────────────────────
// Every term is a config or class question about a hull that cannot change under
// the record, so it is answered once here rather than per tick.
private _flight = [];
private _cruise = 0;

if (_kind == KIND_AIR || {_kind == KIND_BOAT}) then {
    private _isNaval = _kind == KIND_BOAT;
    private _isHeli = !_isPlane && {!_isNaval};

    private _coef = switch (true) do {
        case (_isNaval): {SPEED_BOAT_COEF};
        case (_isPlane): {SPEED_PLANE_COEF};
        default {SPEED_HELI_COEF};
    };

    private _top = getNumber (configOf _hull >> "maxSpeed");
    if (_top <= 0) then {_top = 200};

    _top = (_top * _coef) min SPEED_CAP;

    // The curator's own speed setting still has the last word on pace, as it
    // does for land vehicles
    if ((speedMode (group _unit)) isNotEqualTo "NORMAL") then {
        _top = _top * SPEED_LIMITED_COEF;
    };

    if (_scripted) then {
        // METRES PER SECOND here, where the same figure is KM/H on the limitSpeed
        // branch below. That is not a slip: the scaled-and-capped config number
        // is Wargame's cruise and it is fed straight to setVelocity there, which
        // is why its helicopters cruise at a sane 60 m/s rather than at a config
        // maxSpeed that is a dive figure. Under limitSpeed the engine wants the
        // km/h the config is written in.
        _cruise = _top;

        _flight = [
            _isHeli,
            _isPlane,
            _isNaval,
            switch (true) do {
                case (_isNaval): {FLIGHT_PITCH_BOAT};
                case (_isPlane): {FLIGHT_PITCH_PLANE};
                default {FLIGHT_PITCH_HELI};
            },
            switch (true) do {
                case (_isNaval): {FLIGHT_TURN_BOAT};
                case (_isPlane): {FLIGHT_TURN_PLANE};
                default {FLIGHT_TURN_HELI};
            }
        ];
    } else {
        // limitSpeed rather than forceSpeed: a ceiling still lets the AI slow for
        // terrain, traffic and landing, where a forced speed would fly it into a
        // hill at a constant number.
        _hull limitSpeed _top;
    };
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
    _arrival,
    _facing,
    "",       // FOLLOW_ANIM — not puppeted yet; the launch does that
    -1,       // FOLLOW_ANIM_EH — no AnimDone handler installed
    -1,       // FOLLOW_HIT_EH — no Hit handler installed
    0,        // FOLLOW_RETRY_AT — the driving path has never been re-asserted
    // When the launch is due, and the settle a re-task gets before it. Kept
    // afterwards rather than cleared — FOLLOW_LAUNCHED is what says the order has
    // gone out, and a scripted flight still wants this as the clock its liftoff
    // grace is measured from.
    _now + ([0, RETASK_SETTLE] select _retask),
    -1,       // FOLLOW_SPAN — before the first facing span
    _scripted,
    objNull,  // FOLLOW_TARGET — not engaging
    0,        // FOLLOW_ENGAGE_AT — no cooldown outstanding
    0,        // FOLLOW_SPEED — at rest as far as the flight model is concerned
    _cruise,
    _flight,
    getPosASL _hull,
    false     // FOLLOW_LAUNCHED — nothing has been ordered yet
];

// Created by the first path, destroyed by the last (FUNC(followTick)) — the
// idle cost of this component on a machine with nothing following is nothing
if (GVAR(pfh) == -1) then {
    GVAR(pfh) = [LINKFUNC(followTick), TICK_INTERVAL] call CBA_fnc_addPerFrameHandler;
};
