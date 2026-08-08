#include "script_component.hpp"
/*
 * Author: Maxim
 * The engine behind every reverse maneuver running on this machine: one shared
 * per-frame handler walking GVAR(active), created by the first maneuver
 * (FUNC(reverseTo)) and removed by the last. Idle cost is therefore not "small",
 * it is nothing — the handler does not exist between maneuvers.
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
 *
 * Two details the previous straight-line implementation got wrong, both fixed by
 * the record layout rather than by extra checks:
 *
 *  - The push follows the axis captured at ORDER time, not the hull's live
 *    facing. A hull sliding backward yaws under physics, and steering the push
 *    by live facing curves the vehicle off the line the curator was shown.
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
 * [rtz_reverse_fnc_reverseTick, 0] call CBA_fnc_addPerFrameHandler
 *
 * Public: No
 */

// Last maneuver finished on the previous pass — take the loop down rather than
// leave it spinning over an empty array for the rest of the mission
if (GVAR(active) isEqualTo []) exitWith {
    [GVAR(pfh)] call CBA_fnc_removePerFrameHandler;
    GVAR(pfh) = -1;
};

// Backwards, so a finished maneuver can be deleted without disturbing the
// indices of the ones not visited yet
for "_i" from (count GVAR(active)) - 1 to 0 step -1 do {
    private _record = GVAR(active) select _i;
    _record params ["_vehicle", "_driver", "_axis", "_destination", "_endTime", "_movedAt", "_checkAt"];

    // Only x/y matter: the destination sits on the ground plane and the axis is
    // flat, so the vertical difference is noise from suspension and terrain
    private _toDestination = _destination vectorDiff (getPos _vehicle);
    private _remaining = (_toDestination select 0) * (_axis select 0) + (_toDestination select 1) * (_axis select 1);

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
    // and endReverse's driver restore not running until that long after the
    // handover.
    private _finished = !alive _vehicle
        || {!local _vehicle}
        || {_remaining <= 0}
        || {_vehicle distance2D _destination <= ARRIVAL_DISTANCE};

    if (!_finished && {CBA_missionTime >= _checkAt}) then {
        _record set [MANEUVER_CHECK_AT, CBA_missionTime + CHECK_INTERVAL];

        // Stuck detection: the clock only advances while the vehicle is actually
        // moving, so it measures time spent going nowhere rather than time since
        // the order. Sampled here rather than per frame — five seconds of not
        // moving is not a judgement that needs sixty looks a second.
        if (abs speed _vehicle > STUCK_SPEED) then {
            _movedAt = CBA_missionTime;
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
            || {CBA_missionTime > _endTime}
            || {CBA_missionTime - _movedAt > STUCK_TIME};
    };

    if (_finished) then {
        [_record] call FUNC(endReverse);
        GVAR(active) deleteAt _i;
        continue;
    };

    // Push along the fixed axis; the vertical component is left alone so
    // gravity, suspension and terrain still own the vehicle's height
    _vehicle setVelocity [
        (_axis select 0) * REVERSE_SPEED_MS,
        (_axis select 1) * REVERSE_SPEED_MS,
        (velocity _vehicle) select 2
    ];
};
