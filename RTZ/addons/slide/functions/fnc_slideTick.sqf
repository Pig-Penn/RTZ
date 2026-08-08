#include "script_component.hpp"
/*
 * Author: Maxim
 * The engine behind every straight-line drive running on this machine: one
 * shared per-frame handler walking GVAR(active), created by the first maneuver
 * (FUNC(slideTo)) and removed by the last. Idle cost is therefore not "small",
 * it is nothing — the handler does not exist between maneuvers.
 *
 * Forward and reverse are the same code path. A record carries a direction of
 * travel and a speed, never a flag, so nothing in this loop branches on which
 * kind of order it is driving.
 *
 * The per-frame rate is spent on the two things that need it and nothing else:
 *
 *  - The velocity push. setVelocity sets absolute velocity, so anything slower
 *    than every frame lets rolling resistance eat the speed back between ticks
 *    and the vehicle visibly pulses. This is the reason the handler runs at 0.
 *  - The arrival test, which is what stops the vehicle on its mark instead of a
 *    tick-length overshoot past it.
 *
 * Every other reason a maneuver ends — driver lost, vehicle wrecked or
 * immobilised, ownership moved, timeout, stuck — changes on human timescales and
 * is re-checked at CHECK_INTERVAL instead, per maneuver on its own stagger. That
 * is roughly a dozen engine calls per vehicle traded from ~60 Hz down to 4 Hz.
 * The same reasoning shapes what is READ per frame: the loop pulls the four
 * fields the push needs out of the record by index, and leaves the abort tests'
 * fields to the throttled block that actually uses them.
 *
 * Two details the original straight-line implementation got wrong, both fixed by
 * the record layout rather than by extra checks:
 *
 *  - The push follows the axis captured at ORDER time, not the hull's live
 *    facing. A hull under a scripted slide yaws under physics, and steering the
 *    push by live facing curves the vehicle off the line the curator was shown.
 *  - Overshoot is measured against that same fixed axis. Measured against live
 *    facing, a hull that yaws past 90 degrees reports "arrived" the instant it
 *    does so, wherever it happens to be.
 *
 * Arguments:
 * None (CBA per-frame handler)
 *
 * Return Value:
 * None
 *
 * Example:
 * [rtz_slide_fnc_slideTick, 0] call CBA_fnc_addPerFrameHandler
 *
 * Public: No
 */

// Last maneuver finished on the previous pass — take the loop down rather than
// leave it spinning over an empty array for the rest of the mission
if (GVAR(active) isEqualTo []) exitWith {
    [GVAR(pfh)] call CBA_fnc_removePerFrameHandler;
    GVAR(pfh) = -1;
};

// Read once for the whole pass, not once per test: every maneuver on this frame
// is judged against the same instant anyway, and the throttled block below would
// otherwise ask for the clock four more times per vehicle.
private _time = CBA_missionTime;

// Backwards, so a finished maneuver can be deleted without disturbing the
// indices of the ones not visited yet
for "_i" from (count GVAR(active)) - 1 to 0 step -1 do {
    private _record = GVAR(active) select _i;
    private _vehicle = _record select MANEUVER_VEHICLE;
    private _destination = _record select MANEUVER_DESTINATION;
    (_record select MANEUVER_AXIS) params ["_axisX", "_axisY"];

    // One position read serves both distance tests below. Only x/y matter: the
    // destination sits on the ground plane and the axis is flat, so the vertical
    // difference is noise from suspension and terrain.
    private _position = getPos _vehicle;
    private _offsetX = (_destination select 0) - (_position select 0);
    private _offsetY = (_destination select 1) - (_position select 1);

    // Signed distance still to run, along the direction of travel
    private _remaining = _offsetX * _axisX + _offsetY * _axisY;

    // `alive` earns its place on the frame path despite being a state check:
    // it also answers objNull, so a vehicle destroyed or deleted out from under
    // the maneuver (rtz_delete does exactly that) stops being pushed on the
    // frame it dies rather than up to CHECK_INTERVAL later, which is the
    // difference between a clean stop and a wreck that slides for a quarter
    // second after exploding.
    // `local` sits here for the same reason as `alive`, and is just as cheap: it
    // gates the setVelocity at the bottom of this loop. Left in the throttled
    // block below it, an ownership transfer mid-slide meant up to CHECK_INTERVAL
    // of pushing a hull this machine no longer drives — silently doing nothing —
    // and endSlide's driver restore not running until that long after the
    // handover.
    // The arrival backstop is the squared length against ARRIVAL_DISTANCE_SQ
    // rather than distance2D: the offset is already in hand, so the engine call
    // and its square root buy nothing.
    private _finished = !alive _vehicle
        || {!local _vehicle}
        || {_remaining <= 0}
        || {_offsetX * _offsetX + _offsetY * _offsetY <= ARRIVAL_DISTANCE_SQ};

    if (!_finished && {_time >= (_record select MANEUVER_CHECK_AT)}) then {
        _record set [MANEUVER_CHECK_AT, _time + CHECK_INTERVAL];

        private _driver = _record select MANEUVER_DRIVER;
        private _movedAt = _record select MANEUVER_MOVED_AT;

        // Stuck detection: the clock only advances while the vehicle is actually
        // moving, so it measures time spent going nowhere rather than time since
        // the order. Sampled here rather than per frame — five seconds of not
        // moving is not a judgement that needs sixty looks a second.
        if (abs speed _vehicle > STUCK_SPEED) then {
            _movedAt = _time;
            _record set [MANEUVER_MOVED_AT, _movedAt];
        };

        _finished =
            // Ownership (!local) is tested per frame above, not here — it decides
            // whether the setVelocity at the bottom of the loop does anything.
            !canMove _vehicle
            // Not "is there a driver" but "is it still HIM" — a swapped seat ends
            // this maneuver so teardown can release the unit it actually disabled
            || {(driver _vehicle) isNotEqualTo _driver}
            || {!alive _driver}
            || {isPlayer _driver}
            || {_time > (_record select MANEUVER_END_TIME)}
            || {_time - _movedAt > STUCK_TIME};
    };

    if (_finished) then {
        [_record] call FUNC(endSlide);
        GVAR(active) deleteAt _i;
        continue;
    };

    // Push along the fixed axis; the vertical component is left alone so
    // gravity, suspension and terrain still own the vehicle's height
    private _speed = _record select MANEUVER_SPEED;
    _vehicle setVelocity [
        _axisX * _speed,
        _axisY * _speed,
        (velocity _vehicle) select 2
    ];
};
