#include "script_component.hpp"
/*
 * Author: Maxim
 * The engine behind every path running on this machine: ONE shared handler
 * walking GVAR(active), created by the first path (FUNC(startFollow)) and
 * removed by the last. Between paths the handler does not exist, so the idle
 * cost is not small — it is nothing.
 *
 * Wargame's equivalent is three per-frame handlers PER UNIT — steering at 0.001,
 * a combat check at 0.1 and a door check at 0.5 — plus a fourth at 0.0005 for
 * anything that flies. On the kind of session RTZ is built for (several
 * curators, large unit counts, operations lasting hours) that is the one part of
 * its design that could not be carried over at any quality. Everything else
 * about it could, and now is.
 *
 * TWO CADENCES, because there are two kinds of work here:
 *
 *  - MOVEMENT — steering a puppet toward its leg, setting an aircraft's attitude
 *    and velocity. Runs on every wake for the records that need it, which is
 *    every scripted man, aircraft and boat. A land vehicle has no movement half:
 *    the engine drives it.
 *
 *  - CONDITIONS — alive, local, still in the seat, stuck, arrived, engaging,
 *    doors. Every one of these changes on human timescales, so they ride a
 *    half-second stagger that also spreads them so paths are examined a few at a
 *    time rather than all on the same tick.
 *
 * Ten wakes a second is the whole budget for both scripted executors, and it is
 * enough because neither integrates anything: setVelocity persists until
 * something changes it, and a movement animation carries a man along on its own
 * between steering corrections.
 *
 * Three executors come out of the branch at the bottom:
 *
 *  - Land: the engine drives via setDriveOnPath. The only questions left are
 *    whether it has arrived, whether a patrol lap should restart it, and whether
 *    the engine has quietly dropped the path (see DRIVE_RETRY_TIME).
 *
 *  - Scripted flight: FUNC(flightTick), which moves the hull directly.
 *
 *  - Everything else — a puppeted man, and anything on the AI executor — walks
 *    the leg chain here. Whether a man is carried by an animation or handed a
 *    doMove is decided per leg by whether FUNC(moveAnimation) named one, so the
 *    scripted executor, the marked-stretch executor and the pure-AI executor are
 *    the same code with a different answer to one question.
 *
 * The doMove half is the interesting one. A doMove chain does not survive the
 * formation FSM on its own — a subordinate is pulled back into formation within
 * seconds of being given an order — and re-issuing doMove every tick to beat it
 * makes the AI re-plan constantly and visibly stutter. So the order is
 * re-asserted only when expectedDestination shows the AI's own plan has drifted
 * off this path's current leg, which is exactly when it was stolen and never
 * otherwise. That read is locality-bound and legal here precisely because this
 * runs on the owner (Gotchas §4). The technique is LAMBS'
 * (lambs_main_fnc_doAssault).
 *
 * Arguments:
 * None (CBA per-frame handler)
 *
 * Return Value:
 * None
 *
 * Example:
 * [rtz_path_fnc_followTick, TICK_INTERVAL] call CBA_fnc_addPerFrameHandler
 *
 * Public: No
 */

private _active = GVAR(active);

// Last path finished on the previous pass — take the loop down rather than
// leave it spinning over an empty array for the rest of the mission
if (_active isEqualTo []) exitWith {
    [GVAR(pfh)] call CBA_fnc_removePerFrameHandler;
    GVAR(pfh) = -1;
};

private _now = CBA_missionTime;

// Backwards, so a finished path can be deleted without disturbing the indices
// of the ones not visited yet
for "_i" from (count _active) - 1 to 0 step -1 do {
    private _record = _active select _i;
    _record params ["_unit", "_hull", "_points", "_index", "_kind", "_patrol", "_endTime", "_movedAt", "_checkAt", "", "_arrival", "_facing", "_anim"];

    private _scripted = _record select FOLLOW_SCRIPTED;

    // Records on a scripted executor are MOVED every time the handler wakes, and
    // so is one merely passing through a marked stretch — a hull being turned by
    // hand twice a second reads as a model snapping round rather than as a
    // soldier turning. Everything else only ever costs the half-second stagger.
    // This is the whole per-tick cost of the component, and it is bounded by what
    // is actually being executed rather than by what exists.
    private _moves = (_scripted || {_anim isNotEqualTo ""}) && {_kind != KIND_LAND};
    private _due = _now >= _checkAt;

    if (!_moves && {!_due}) then {continue};

    // The settle between a re-task's teardown and its launch. Nothing at all
    // happens to the record in between — it is not stuck, it has not arrived, it
    // is waiting.
    if (!(_record select FOLLOW_LAUNCHED) && {_now < (_record select FOLLOW_START_AT)}) then {continue};

    // Checked on every wake rather than on the stagger, because the two things
    // this catches are the two that must never be steered: a dead man is not
    // walked, and a destroyed hull is not given a velocity.
    private _finished = isNull _unit || {!alive _unit} || {!alive _hull};

    if (_due && {!_finished}) then {
        _record set [FOLLOW_CHECK_AT, _now + CHECK_INTERVAL];

        // The stuck clock only advances while the unit is actually moving, so it
        // measures time spent going nowhere rather than time since the order
        if (abs speed _hull > STUCK_SPEED) then {
            _movedAt = _now;
            _record set [FOLLOW_MOVED_AT, _movedAt];
        };

        _finished =
            // Ownership moved mid-path (rtz_control's transfer, a JIP handover,
            // a headless client rebalancing). Orders issued from here would
            // silently do nothing from now on, so let go cleanly instead.
            !local _unit
            || {!canMove _hull}
            // A player took the controls — including a curator remote-controlling
            // the unit, which isPlayer also reports
            || {isPlayer _unit}
            // Not "is there a driver" but "is it still HIM": a swapped seat ends
            // this path so teardown releases the unit it actually stopped
            || {_kind != KIND_INFANTRY && {(driver _hull) isNotEqualTo _unit}}
            || {_now > _endTime}
            || {_now - _movedAt > STUCK_TIME};
    };

    if (!_finished && {!(_record select FOLLOW_LAUNCHED)}) then {
        [_record] call FUNC(launchFollow);
    };

    // Land vehicles are being driven by the engine and need nothing advanced;
    // the only question left is whether they have arrived. Written as if/else
    // rather than a switch on purpose — a `continue` inside a switch case does
    // not reach the loop around it (Gotchas §2), and this body needs to stay
    // safe to add one to.
    if (!_finished && {_kind == KIND_LAND}) then {
        if ((_hull distance2D (ASLToAGL (_points select -1))) <= _arrival) then {
            if (_patrol) then {
                _hull setDriveOnPath (_record select FOLLOW_DRIVE);
                // A lap boundary is not a stall, however slow the vehicle was
                // as it came round
                _record set [FOLLOW_MOVED_AT, _now];
            } else {
                _finished = true;
            };
        } else {
            // Still on the way, and stationary long enough that the engine has
            // dropped the path rather than the vehicle merely being slow. Only
            // re-asserted while it is still sitting on its first leg — see
            // DRIVE_RETRY_DIST for why re-issuing later would be worse than the
            // stall it is fixing.
            //
            // The retry rides its OWN clock and deliberately does not touch
            // MOVED_AT. Resetting the stuck timer here would mean a vehicle that
            // can never start is re-issued every DRIVE_RETRY_TIME for the whole
            // of GVAR(timeout) instead of being given up at STUCK_TIME — the
            // retry would defeat the check that exists to end exactly this case.
            // Left alone, the stuck clock runs on underneath and allows about
            // five attempts before abandoning the path.
            if (_now - _movedAt > DRIVE_RETRY_TIME
                && {_now > (_record select FOLLOW_RETRY_AT)}
                && {(_hull distance2D (ASLToAGL (_points select 0))) <= DRIVE_RETRY_DIST}
            ) then {
                _hull setDriveOnPath (_record select FOLLOW_DRIVE);
                _record set [FOLLOW_RETRY_AT, _now + DRIVE_RETRY_TIME];
            };
        };
    };

    // Aircraft and boats being flown by hand. Everything about the step lives in
    // FUNC(flightTick), including which leg it is on, because none of it is
    // shared with the chain below.
    if (!_finished && {_scripted} && {_kind == KIND_AIR || {_kind == KIND_BOAT}}) then {
        _finished = [_record, _now] call FUNC(flightTick);
    };

    // Everything else: a puppeted man, and anything at all on the AI executor.
    if (!_finished && {_kind == KIND_INFANTRY || {!_scripted}} && {_kind != KIND_LAND}) then {
        // Broken off to fight, or deciding whether to. Only ever asked on the
        // stagger — the answer cannot change usefully faster than that — and only
        // for a man who is or is about to be a puppet, since one on his own
        // navigation is already reacting for himself.
        private _engaging = !isNull (_record select FOLLOW_TARGET);

        if (_kind == KIND_INFANTRY && {_due} && {_scripted || {_anim isNotEqualTo ""} || {_engaging}}) then {
            _engaging = [_record, _now] call FUNC(combatPause);

            // Stopping to shoot is not being stuck. Without this a firefight
            // longer than STUCK_TIME abandons the path of every unit in it.
            if (_engaging) then {_record set [FOLLOW_MOVED_AT, _now]};
        };

        if (!_engaging) then {
            private _count = count _points;
            private _wasIndex = _index;

            // Credit every leg already inside the arrival radius, not just one
            // per tick. A drawn corner puts several points within a few metres of
            // each other, and walking them off one tick at a time stalls the unit
            // on the inside of the turn.
            private _skips = 0;
            while {
                _skips < MAX_SKIP
                && {_index < _count}
                && {(_hull distance2D (ASLToAGL (_points select _index))) <= _arrival}
            } do {
                _index = _index + 1;
                _skips = _skips + 1;
            };

            if (_index >= _count) then {
                if (_patrol) then {
                    _index = 0;
                    // A lap starts the facing spans again from the beginning;
                    // the cursor only ever moves forward within one lap.
                    _record set [FOLLOW_SPAN, -1];
                } else {
                    _finished = true;
                };
            };

            if (!_finished) then {
                _record set [FOLLOW_INDEX, _index];

                private _target = ASLToAGL (_points select _index);

                // Which facing span this leg falls under. The spans are ascending
                // and so are the legs, so the cursor walks forward with them and
                // never scans: a path with fifty spans costs the same integer
                // compare per tick as one with none. Wargame's per-point payload
                // buys the same O(1) answer at the price of three numbers on
                // every point of every path.
                private _span = _record select FOLLOW_SPAN;
                private _spanCount = count _facing;

                while {_span + 1 < _spanCount && {((_facing select (_span + 1)) select 0) <= _index}} do {
                    _span = _span + 1;
                };

                _record set [FOLLOW_SPAN, _span];

                private _azimuth = FACING_NONE;
                if (_span >= 0) then {_azimuth = (_facing select _span) select 1};

                // Read out by hand rather than with `params`: `params` declares
                // its variables private to the CURRENT scope, and inside a `then`
                // block that scope is the block — so it would shadow both of
                // these and throw the answer away the moment the block ended.
                private _want = "";
                private _offset = 0;

                // A scripted man is carried by an animation for EVERY leg, facing
                // where he is going unless a span says otherwise. On the other two
                // executors only a marked span asks for one. This single condition
                // is the entire difference between the three.
                if (_scripted || {_azimuth != FACING_NONE}) then {
                    private _resolved = [_unit, _hull getDir _target, _azimuth] call FUNC(moveAnimation);
                    _want = _resolved select 0;
                    _offset = _resolved select 1;
                };

                // Enters the puppet, swaps which animation it is walking on, or
                // leaves — and does nothing at all when neither this tick nor the
                // last wanted one, which is every tick of an AI-executor path.
                //
                // "" is also the fallback when no animation exists for this
                // stance, weapon and direction: the leg degrades to a move order
                // rather than to a man standing still with MOVE disabled, which
                // is what Wargame does with an unresolved name.
                [_record, _want] call FUNC(setPuppet);

                if (_want isNotEqualTo "") then {
                    // Doors, for a man who has no AI movement left to open one
                    // with. On the stagger, and only while he is actually a
                    // puppet — outside that his own AI does it.
                    if (_due) then {[_unit] call FUNC(openDoors)};

                    // Steering by hand, because MOVE is off and the animation
                    // carries the unit along its own facing rather than along the
                    // leg. Swing the hull a step at a time toward the leg — offset
                    // by however far this animation strafes off the nose — rather
                    // than setting the heading outright, which would spin the model
                    // on the spot every time the line bent.
                    private _relative = ((_unit getRelDir _target) + _offset) % 360;

                    // Which way round is shorter, and how far it actually is. A
                    // relative bearing under 180 is clockwise of the nose.
                    private _right = _relative < 180;
                    private _error = [360 - _relative, _relative] select _right;

                    // Clamped to the error, so the hull LANDS on the heading and
                    // stops. Wargame steps by a fixed amount and therefore hunts a
                    // degree or so either side of the answer for as long as the path
                    // lasts — invisible at its cadence, a shiver at this one.
                    private _step = ([TACTICAL_TURN_COARSE, TACTICAL_TURN_FINE] select (_error < TACTICAL_TURN_ALIGNED)) min _error;

                    // Already there. Skipped rather than written as a zero rotation:
                    // this is an animation-driven unit, and the fewer frames its
                    // orientation is set from outside the animation the better.
                    if (_step > 0) then {
                        (vectorDir _unit) params ["_vx", "_vy"];

                        private _turn = [_step, -_step] select _right;

                        _unit setVectorDir [
                            (cos _turn * _vx) - (sin _turn * _vy),
                            (sin _turn * _vx) + (cos _turn * _vy),
                            0
                        ];
                    };
                } else {
                    // Cruise height is a property of the leg, so it is set when the
                    // leg changes and not on every tick that passes over it
                    if (_kind == KIND_AIR && {_index != _wasIndex}) then {
                        _hull flyInHeight (_target select 2);
                    };

                    // expectedDestination reports [0,0,0] when the AI has no plan at
                    // all, which fails this test and re-issues — correct, since no
                    // plan is the strongest reason there is to re-assert.
                    if (((expectedDestination _unit) select 0) distance2D _target > REPLAN_TOLERANCE) then {
                        _unit doMove _target;
                    };
                };
            };
        };
    };

    if (_finished) then {
        [_record] call FUNC(endFollow);
        _active deleteAt _i;
    };
};
