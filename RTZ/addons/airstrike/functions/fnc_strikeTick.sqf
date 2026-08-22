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
                    // Task 5 replaces this with the hand-off onto the rail.
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
