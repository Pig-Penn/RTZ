#include "script_component.hpp"
/*
 * Author: Maxim
 * Starts (or re-points) a straight-line drive on one vehicle. Must run where the
 * vehicle is local — FUNC(orderSlide) targets this per vehicle for exactly that
 * reason.
 *
 * AI cannot be commanded to drive backward through its normal navigation — a
 * long-standing engine limitation (BI feedback T75076), and not one this can
 * route around: the engine's only reverse order, sendSimpleCommand "BACK", is
 * restricted to vehicles crewed by a player, which is the one case that never
 * applies to a Zeus ordering AI. So the driver comes off the AI navigation stack
 * and the vehicle is pushed directly with setVelocity by FUNC(slideTick).
 * Forward orders take the same path rather than a doMove, because a doMove
 * answers a different question — see script_component.hpp.
 *
 * Direction is not a parameter here. It arrives already resolved into the axis
 * and the speed, so this function, the record it writes and the engine that
 * drives it are all identical for the two orders.
 *
 * This function only registers the maneuver; nothing here loops. Every running
 * maneuver lives as one record in GVAR(active) (layout in script_component.hpp)
 * and a single shared per-frame handler drives all of them, so ten driving
 * vehicles cost one handler rather than ten. The handler is created on the first
 * maneuver and destroyed with the last, so a mission where nobody ever uses the
 * keybind pays nothing at all.
 *
 * Re-ordering a vehicle that is already driving supersedes the old order instead
 * of stacking a second slide on top of it — including a reverse that supersedes
 * a forward, which needs nothing special: the record simply takes the new axis
 * and the new speed. Which of the two supersede paths applies turns on whether
 * the driver is still the same unit — see below; that distinction is what keeps
 * a swapped-out driver from being stranded with his AI disabled.
 *
 * Arguments:
 * 0: Vehicle <OBJECT>
 * 1: Direction of travel, unit vector on the ground plane <ARRAY>
 * 2: Destination AGL <ARRAY>
 * 3: Speed <NUMBER> - m/s along that axis
 *
 * Return Value:
 * None
 *
 * Example:
 * [_vehicle, _axis, _pos, REVERSE_SPEED_MS] call rtz_slide_fnc_slideTo
 *
 * Public: No
 */

params ["_vehicle", "_axis", "_destination", "_speed"];

// Both can have changed in the time the order spent on the wire: ownership can
// move (rtz_control hands vehicles between machines outright), and the driver
// can be killed or bail out between the keystroke and this call.
if (!local _vehicle) exitWith {};
if !([_vehicle] call FUNC(canSlide)) exitWith {};

private _driver = driver _vehicle;
private _endTime = CBA_missionTime + GETGVAR(timeout,10);

private _start = true;
private _index = GVAR(active) findIf {(_x select MANEUVER_VEHICLE) isEqualTo _vehicle};

if (_index != -1) then {
    private _record = GVAR(active) select _index;

    if ((_record select MANEUVER_DRIVER) isEqualTo _driver) then {
        // Same driver, new heading: re-point the existing record and restart its
        // clocks. Deliberately does not tear down and rebuild — the driver is
        // already off the navigation stack and the brakes are already released,
        // and cycling them would hand him back to formation for a frame, which
        // reads as a stutter mid-slide.
        _record set [MANEUVER_AXIS, _axis];
        _record set [MANEUVER_DESTINATION, _destination];
        _record set [MANEUVER_SPEED, _speed];
        _record set [MANEUVER_END_TIME, _endTime];
        _record set [MANEUVER_MOVED_AT, CBA_missionTime];
        _record set [MANEUVER_CHECK_AT, CBA_missionTime + CHECK_INTERVAL];

        _start = false;
    } else {
        // The seat changed hands since the last order. The unit the old record
        // disabled is not the one about to be disabled, so it has to be released
        // through the normal teardown first — drop the record on the floor
        // instead and that unit keeps MOVE/PATH off for the rest of the mission,
        // because nothing else remembers it was ever touched.
        [_record] call FUNC(endSlide);
        GVAR(active) deleteAt _index;
    };
};

if (_start) then {
    // Take the driver off the AI navigation stack for the duration so he stops
    // fighting (or simply ignoring) the scripted movement. The parking brake
    // must also be released: doStop leaves it engaged since the AI has no active
    // move order, which otherwise locks the wheel-rotation animation while
    // setVelocity physically slides the vehicle along.
    doStop _driver;
    _driver disableAI "MOVE";
    _driver disableAI "PATH";
    _vehicle disableBrakes true;

    GVAR(active) pushBack [
        _vehicle, _driver, _axis, _destination, _speed,
        _endTime, CBA_missionTime, CBA_missionTime + CHECK_INTERVAL
    ];

    if (GVAR(pfh) == -1) then {
        GVAR(pfh) = [LINKFUNC(slideTick), 0] call CBA_fnc_addPerFrameHandler;
    };
};
