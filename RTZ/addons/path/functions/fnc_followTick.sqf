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
 * its design that could not be carried over at any quality.
 *
 * NOTHING here needs the frame rate, and that is a consequence of the executors
 * chosen rather than a corner cut. No object is pushed around by hand: the
 * engine drives land vehicles via setDriveOnPath, and the AI walks, flies and
 * sails everything else along a doMove chain. Advancing a leg, noticing an
 * arrival and every abort condition change on human timescales, so the handler
 * wakes at TICK_INTERVAL and each record rides its own CHECK_INTERVAL stagger
 * inside that — which also means paths are examined a few at a time rather than
 * all of them on the same tick.
 *
 * The chain is the interesting part. A doMove chain does not survive the
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
    _record params ["_unit", "_hull", "_points", "_index", "_kind", "_patrol", "_endTime", "_movedAt", "_checkAt", "_drive", "_arrival"];

    if (_now < _checkAt) then {continue};
    _record set [FOLLOW_CHECK_AT, _now + CHECK_INTERVAL];

    // The stuck clock only advances while the unit is actually moving, so it
    // measures time spent going nowhere rather than time since the order
    if (abs speed _hull > STUCK_SPEED) then {
        _movedAt = _now;
        _record set [FOLLOW_MOVED_AT, _movedAt];
    };

    private _finished = !alive _unit
        || {!alive _hull}
        // Ownership moved mid-path (rtz_control's transfer, a JIP handover, a
        // headless client rebalancing). Orders issued from here would silently
        // do nothing from now on, so let go cleanly instead.
        || {!local _unit}
        || {!canMove _hull}
        // A player took the controls — including a curator remote-controlling
        // the unit, which isPlayer also reports
        || {isPlayer _unit}
        // Not "is there a driver" but "is it still HIM": a swapped seat ends
        // this path so teardown releases the unit it actually stopped
        || {_kind != KIND_INFANTRY && {(driver _hull) isNotEqualTo _unit}}
        || {_now > _endTime}
        || {_now - _movedAt > STUCK_TIME};

    // Land vehicles are being driven by the engine and need nothing advanced;
    // the only question left is whether they have arrived. Written as if/else
    // rather than a switch on purpose — a `continue` inside a switch case does
    // not reach the loop around it (Gotchas §2), and this body needs to stay
    // safe to add one to.
    if (!_finished && {_kind == KIND_LAND}) then {
        if ((_hull distance2D (ASLToAGL (_points select -1))) <= _arrival) then {
            if (_patrol) then {
                _hull setDriveOnPath _drive;
                // A lap boundary is not a stall, however slow the vehicle was
                // as it came round
                _record set [FOLLOW_MOVED_AT, _now];
            } else {
                _finished = true;
            };
        };
    };

    // Everything else — men, aircraft and boats alike — walks, flies or sails
    // the same doMove chain. They differ only in how close counts as arrived
    // and, for aircraft, in the cruise height each leg is flown at.
    if (!_finished && {_kind != KIND_LAND}) then {
        private _count = count _points;
        private _wasIndex = _index;

        // Credit every leg already inside the arrival radius, not just one per
        // tick. A drawn corner puts several points within a few metres of each
        // other, and walking them off one tick at a time stalls the unit on the
        // inside of the turn.
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
            if (_patrol) then {_index = 0} else {_finished = true};
        };

        if (!_finished) then {
            _record set [FOLLOW_INDEX, _index];

            private _target = ASLToAGL (_points select _index);

            // Cruise height is a property of the leg, so it is set when the leg
            // changes and not on every tick that passes over it
            if (_kind == KIND_AIR && {_index != _wasIndex}) then {
                _hull flyInHeight (_target select 2);
            };

            // expectedDestination reports [0,0,0] when the AI has no plan at
            // all, which fails this test and re-issues — correct, since no plan
            // is the strongest reason there is to re-assert.
            if (((expectedDestination _unit) select 0) distance2D _target > REPLAN_TOLERANCE) then {
                _unit doMove _target;
            };
        };
    };

    if (_finished) then {
        [_record] call FUNC(endFollow);
        _active deleteAt _i;
    };
};
