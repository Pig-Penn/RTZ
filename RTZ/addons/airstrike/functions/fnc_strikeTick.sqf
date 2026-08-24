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
 * The ingress converges on the run-in AXIS, not the run-in POINT. Steering straight at
 * the point is the obvious thing and it does not work: the aircraft arrives on whatever
 * heading it happened to approach from, the heading gate rejects it, and it sails past
 * and comes round again on a fresh arbitrary heading until INGRESS_TIMEOUT. Chasing a
 * carrot that slides along the axis closes the lateral offset and drives forward down
 * the line at once, so the aircraft is already tracking the run-in before it reaches it.
 *
 * Both ends of the rail are eased rather than cut. On final the carrot becomes the mark,
 * so FUNC(steerToward)'s rate-limited pitch has the nose most of the way into the dive
 * before the rail imposes it; and the pull-off is flown on that same steering for
 * EGRESS_DRIVE seconds, so the pilot is handed a level aircraft instead of one pointed
 * into the ground at attack speed.
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
                private _bearing = _record select STRIKE_BEARING;

                private _pos = getPosASL _vehicle;

                // The run-in AXIS: the horizontal direction the attack run will be flown
                // in, and the right-hand normal to it. Everything below is expressed in
                // those two, because the ingress problem is "get onto this line pointing
                // this way", not "get to this point".
                private _axis = [sin _bearing, cos _bearing, 0];
                private _right = [cos _bearing, -(sin _bearing), 0];

                private _fromStart = _pos vectorDiff _start;

                // Signed. Along is negative BEHIND the run-in start, which is the only
                // place there is an approach left to fly. Lateral is signed too, because
                // the rejoin below needs to know which side to go round on.
                private _along = _fromStart vectorDotProduct _axis;
                private _lateral = _fromStart vectorDotProduct _right;

                private _carrot = if (_along > -(INGRESS_MIN_FINAL)) then {
                    // Level with the run-in start or already past it: there is no
                    // approach left, so rejoin well behind it. Offset to the side the
                    // aircraft is ALREADY on, so it flies a racetrack rather than
                    // reversing head-on through the axis and having to re-cross it.
                    private _side = [-1, 1] select (_lateral >= 0);

                    private _rejoin = _start
                        vectorAdd (_axis vectorMultiply -(RUN_IN_DISTANCE * INGRESS_REJOIN))
                        vectorAdd (_right vectorMultiply (_side * INGRESS_REJOIN_SIDE));

                    _rejoin set [2, _start select 2];
                    _rejoin
                } else {
                    // A carrot sliding along the axis, always INGRESS_LOOKAHEAD ahead of
                    // the aircraft's own projection onto it and never past the run-in
                    // start. Chasing THIS rather than the start point closes the lateral
                    // offset and drives forward along the line at the same time, so the
                    // aircraft rolls onto the axis and is already tracking down it before
                    // it arrives — instead of reaching a spot on whatever heading it
                    // happened to approach from, which is what the gate below used to
                    // reject, sending it round again on a fresh arbitrary heading.
                    private _lead = (_along + INGRESS_LOOKAHEAD) min 0;
                    private _point = _start vectorAdd (_axis vectorMultiply _lead);

                    if (_along > -(FINAL_RANGE)) then {
                        // On final the carrot stops holding run-in altitude and becomes
                        // the mark itself, so the rate-limited pitch eases the nose into
                        // the dive over the last several seconds. By capture the aircraft
                        // is already flying roughly the angle the rail is about to
                        // impose, which is what makes the handover continuous instead of
                        // a one-frame snap — and it costs no fourth phase.
                        _record select STRIKE_AIM
                    } else {
                        _point set [2, _start select 2];
                        _point
                    };
                };

                [_record, _carrot, _delta] call FUNC(steerToward);

                // Crossing the start PLANE, not entering a sphere around the start point:
                // the ingress now arrives along the axis, so "how far down the line am I"
                // is the meaningful test and the radial one would be satisfied off to one
                // side. The other two still both apply, never either — near the line is
                // not the same as pointed along it, and a rail entered off-axis flies a
                // run the curator did not draw. Failing them is self-correcting: _along
                // keeps growing, the rejoin branch above takes over, and the aircraft
                // comes round properly instead of trying again from wherever it drifted.
                if (_along >= 0
                    && {abs _lateral < RUN_IN_CAPTURE}
                    && {abs (((getDir _vehicle) - _bearing + 540) % 360 - 180) < HEADING_TOLERANCE}
                ) then {
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

                    // The rail owns the attitude from here, so the steering's own state
                    // has to be told what the rail just imposed. Without this the pull-off
                    // would start rate-limiting up from whatever the ingress last
                    // commanded — a level attitude the aircraft no longer has — and the
                    // first egress tick would snap the nose down into the dive it has
                    // just finished, which is exactly the artefact this phase exists to
                    // remove.
                    _record set [STRIKE_PITCH, _pitch];
                    _record set [STRIKE_BANK, 0];

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

                if (!(_record select STRIKE_FIRE_DONE)
                    && {!isNull (_record select STRIKE_LASER) || {(getPosASL _vehicle) distance _aim < _range}}
                ) then {
                    _record set [STRIKE_FIRE_DONE, [_record, _now] call FUNC(release)];
                };

                if ((_now - _t0) >= _duration) then {
                    _record set [STRIKE_PHASE, PHASE_EGRESS];
                    _record set [STRIKE_PHASE_AT, _now + EGRESS_TIMEOUT];

                    // Where the pull-off is heading: on along the run-in bearing, back up
                    // at run-in altitude. Resolved ONCE here rather than per tick below,
                    // because getTerrainHeightASL on a frame path is exactly the kind of
                    // engine call this component keeps off it.
                    private _egress = _aim getPos [EGRESS_DISTANCE, _record select STRIKE_BEARING];
                    _egress set [2, (getTerrainHeightASL _egress) + RUN_IN_ALTITUDE];

                    _record set [STRIKE_EGRESS, _egress];

                    // The aircraft is NOT handed back yet. It was, and the AI inherited a
                    // hull pointed twenty degrees into the ground at attack speed, which
                    // it recovered from in its own time and its own way — the jarring part
                    // of the whole run. The pull-off is flown for EGRESS_DRIVE seconds by
                    // the same rate-limited steering as the ingress, so the nose comes up
                    // at PITCH_RATE and the turn-out banks, and only then does the pilot
                    // get a level aircraft back.
                    _record set [STRIKE_EGRESS_AT, _now + EGRESS_DRIVE];
                };
            };

            case PHASE_EGRESS: {
                private _driveUntil = _record select STRIKE_EGRESS_AT;

                if (_driveUntil > 0) then {
                    [_record, _record select STRIKE_EGRESS, _delta] call FUNC(steerToward);

                    // Ends on the nose being back up, not only on the clock: a shallow gun
                    // run recovers in well under EGRESS_DRIVE and there is no reason to go
                    // on driving a hull that is already flying level.
                    if (_now >= _driveUntil || {(_record select STRIKE_PITCH) > -(EGRESS_LEVEL)}) then {
                        // Handed back HERE rather than at teardown, so the rest of the
                        // pull-off is flown by the pilot and looks like flying rather than
                        // like a scripted object being let go. Teardown still runs the same
                        // restores — they are idempotent, and it is also reached by paths
                        // that never get here. Marked with -1 so this cannot re-fire: the
                        // phase goes on running for as long as it takes the aircraft to get
                        // clear, and re-issuing the order every frame would fight the pilot
                        // it was just given to.
                        _record set [STRIKE_EGRESS_AT, -1];

                        (_record select STRIKE_RESTORE) params ["_move"];

                        if (_move) then {(_record select STRIKE_DRIVER) enableAI "MOVE"};

                        // Carrying the velocity it actually has, so it does not stop dead
                        // in the air on the frame the steering lets go.
                        _vehicle setVelocity (velocity _vehicle);
                        _vehicle flyInHeight RUN_IN_ALTITUDE;
                        _vehicle doMove (ASLToAGL (_record select STRIKE_EGRESS));
                    };
                } else {
                    // Nothing left to drive: the AI has the aircraft back. The phase stays
                    // alive only long enough for it to get clear of its own bombs before
                    // the mark is deleted, and ends on distance or on EGRESS_TIMEOUT.
                    if ((getPosASL _vehicle) distance (_record select STRIKE_AIM) > EGRESS_CLEAR) then {
                        _finished = true;
                    };
                };
            };
        };
    };

    // Everything that changes on human timescales. Roughly a dozen engine calls per
    // aircraft traded from once a frame down to four times a second, on each record's
    // own stagger. Skipped entirely once something faster has already ended the strike.
    if (!_finished && {_now >= (_record select STRIKE_CHECK)}) then {
        _record set [STRIKE_CHECK, _now + CHECK_INTERVAL];

        private _driver = _record select STRIKE_DRIVER;
        (_record select STRIKE_WEAPON) params ["_weapon"];

        _finished =
            // Not "is there a driver" but "is it still HIM" — a swapped seat ends the
            // strike so teardown can restore the unit it actually disabled.
            (driver _vehicle) isNotEqualTo _driver
            || {!alive _driver}
            || {isPlayer _driver}
            // Dry BEFORE the window ever opened: there is nothing left to deliver, so
            // flying the rest of the run is theatre.
            || {(_record select STRIKE_PHASE) != PHASE_EGRESS
                && {isNull (_record select STRIKE_LASER)}
                && {_vehicle ammo _weapon <= 0}};
    };

    if (_finished) then {
        [_record] call FUNC(endStrike);
        GVAR(active) deleteAt _i;
    };
};
