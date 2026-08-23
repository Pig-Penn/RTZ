#include "script_component.hpp"
/*
 * Author: Maxim
 * The engine behind every airstrike running on this machine: one shared per-frame
 * handler walking GVAR(active), created by the first strike (FUNC(executeStrike)) and
 * removed by the last. Idle cost is therefore not "small", it is nothing — the handler
 * does not exist between strikes.
 *
 * Per-frame is spent on the two things that need it and nothing else: the steering or
 * rail push, which sets absolute velocity and visibly stutters at anything slower, and
 * the phase-transition test, which is what puts the aircraft on its rail at the right
 * point instead of a tick-length past it. Every other reason a strike ends changes on
 * human timescales and is re-checked at CHECK_INTERVAL instead — the same split
 * EFUNC(slide,slideTick) makes.
 *
 * Arguments:
 * None (CBA per-frame handler)
 *
 * Return Value:
 * None
 *
 * Example:
 * [rtz_airstrike_fnc_strikeTick, 0] call CBA_fnc_addPerFrameHandler
 *
 * Public: No
 */

// Last strike finished on the previous pass — take the loop down rather than leave it
// spinning over an empty array for the rest of the mission.
if (GVAR(active) isEqualTo []) exitWith {
    [GVAR(pfh)] call CBA_fnc_removePerFrameHandler;
    GVAR(pfh) = -1;
};

private _now = CBA_missionTime;

// Real elapsed time, so the steering turns at TURN_RATE degrees per SECOND rather than
// per frame — otherwise the same order flies differently on a 30 fps server and a
// 120 fps client. Clamped because a frame hitch or a mission-time jump would otherwise
// be handed to the steering as one enormous turn.
private _delta = ((_now - GVAR(lastTick)) max 0) min MAX_DELTA;
GVAR(lastTick) = _now;

// Backwards, so a finished strike can be deleted without disturbing the indices of the
// records not visited yet.
for "_i" from (count GVAR(active)) - 1 to 0 step -1 do {
    private _record = GVAR(active) select _i;
    private _vehicle = _record select STRIKE_PLANE;

    // `alive` earns its place on the frame path despite being a state check: it also
    // answers objNull, so an aircraft deleted out from under the strike — rtz_delete
    // does exactly that — stops being driven on the frame it goes rather than up to
    // CHECK_INTERVAL later. `local` sits here for the same reason and is just as cheap:
    // every command in this loop is a silent no-op without it, and left in the
    // throttled block an ownership transfer meant a quarter second of driving a hull
    // this machine no longer owns, with teardown just as late.
    private _finished = !alive _vehicle
        || {!local _vehicle}
        || {_now > (_record select STRIKE_DEADLINE)}
        || {_now > (_record select STRIKE_PHASE_AT)};

    if (!_finished) then {
        switch (_record select STRIKE_PHASE) do {
            case PHASE_INGRESS: {
                private _start = _record select STRIKE_START;

                [_vehicle, _start, _record select STRIKE_CRUISE, _delta] call FUNC(steerToward);

                // BOTH tests, never either: close enough is not the same as pointed the
                // right way, and a rail entered off-axis flies a run the curator did
                // not draw.
                private _offset = ((getDir _vehicle) - (_record select STRIKE_BEARING) + 540) % 360 - 180;

                if (abs _offset < HEADING_TOLERANCE && {(getPosASL _vehicle) distance _start < RUN_IN_CAPTURE}) then {
                    private _origin = getPosASL _vehicle;
                    private _aim = _record select STRIKE_AIM;
                    private _cruise = _record select STRIKE_CRUISE;

                    private _dir = _origin vectorFromTo _aim;

                    // The dive angle the module uses, from the two legs of the descent
                    // rather than from a fixed number: -90 plus the angle between the
                    // horizontal run and the drop. Floored so an aim point at or above
                    // the aircraft cannot divide by zero.
                    private _horizontal = _origin distance2D _aim;
                    private _drop = (((_origin select 2) - (_aim select 2))) max 1;
                    private _pitch = -90 + atan (_horizontal / _drop);

                    _vehicle setVectorDir _dir;
                    [_vehicle, _pitch, 0] call BIS_fnc_setPitchBank;

                    // Captured ONCE. setVelocityTransformation interpolates between two
                    // fixed states, so re-deriving these every tick would move the
                    // goalposts under the interpolation and the aircraft would never
                    // arrive.
                    _record set [STRIKE_RAIL, [
                        _origin,
                        _dir vectorMultiply _cruise,
                        _dir,
                        vectorUp _vehicle,
                        _now,
                        (_origin distance _aim) / _cruise
                    ]];

                    _record set [STRIKE_PHASE, PHASE_RUN];
                    _record set [STRIKE_PHASE_AT, _now + RUN_TIMEOUT];
                };
            };

            case PHASE_RUN: {
                (_record select STRIKE_RAIL) params ["_origin", "_velocity", "_dir", "_up", "_t0", "_duration"];

                private _aim = _record select STRIKE_AIM;
                private _type = (_record select STRIKE_WEAPON) select 2;

                // The aim point is raised by a per-type offset plus the fire progress.
                // The offset keeps a guided missile from nosing into the dirt short of a
                // ground-level mark; the progress term is the module's own fudge, which
                // walks the burst forward instead of stacking every round on one spot.
                private _target = +_aim;
                _target set [2,
                    (_target select 2)
                    + ((AIM_OFFSET) select _type)
                    + (_record select STRIKE_PROGRESS) * AIM_RAISE
                ];

                _vehicle setVelocityTransformation [
                    _origin, _target,
                    _velocity, _velocity,
                    _dir, _dir,
                    _up, _up,
                    (_now - _t0) / _duration
                ];

                // setVelocityTransformation writes the interpolated state but leaves the
                // engine's own velocity integration to fight it on the next physics step.
                // Re-asserting the velocity it just produced is what keeps the aircraft on
                // the line; both references do exactly this and it is not redundant.
                _vehicle setVelocity (velocity _vehicle);

                // The window opens on slant range, not on rail progress: a bomb wants a
                // long, high release and a gun run a short one, and the two arrive at
                // very different fractions of the same rail. The !isNull half keeps the
                // window open once it HAS opened, so a fast aircraft that overshoots the
                // release range inside one tick still finishes its burst.
                private _range = RELEASE_RANGE select _type;

                if (!isNull (_record select STRIKE_LASER) || {(getPosASL _vehicle) distance _aim < _range}) then {
                    [_record, _now] call FUNC(release);
                };

                if ((_now - _t0) >= _duration) then {
                    // Task 7 replaces this with the hand-off to egress.
                    _finished = true;
                };
            };
        };
    };

    if (_finished) then {
        [_record] call FUNC(endStrike);
        GVAR(active) deleteAt _i;
    };
};
