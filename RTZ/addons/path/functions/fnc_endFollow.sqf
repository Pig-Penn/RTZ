#include "script_component.hpp"
/*
 * Author: Maxim
 * Ends one path and hands back everything it took: the puppet's AI flags,
 * animation and event handlers, the hull's speed ceiling or scripted velocity,
 * and the unit itself, back to its group.
 *
 * Restores the unit the RECORD captured, not whoever is at the controls when the
 * path ends. That distinction is the whole reason the unit is carried in the
 * record at all: a driver who swapped seats mid-path ends the path, and
 * releasing the man now in the seat would leave the one this actually stopped
 * standing still for the rest of the mission.
 *
 * doFollow is the exact inverse of the doStop FUNC(startFollow) issued, so the
 * unit resumes whatever its group was doing rather than being given a new order
 * of its own. A unit that is its own leader follows itself, which is the
 * engine's idiom for "resume normal behaviour" and what LAMBS uses to end its
 * own detached-unit tactics.
 *
 * Leaving the puppet comes FIRST and is unconditional, before any of the tests
 * below can decline to do anything. That executor holds AI feature flags, a
 * looping animation and two event handlers rather than an order, so a path
 * abandoned because the unit died, was deleted or changed machine has to give
 * them back on the way out — and those are precisely the cases the doFollow
 * below correctly skips. Owning the restore here rather than in the AnimDone
 * handler that does the looping is the same rule as everywhere else: an event
 * that is merely likely to fire cannot be the only path back (Gotchas §1).
 *
 * Handing an AIRCRAFT back is its own problem, and the one place Wargame's
 * design cannot simply be dropped. A hull that has been moved by setVelocity for
 * the last several minutes is, the instant that stops, an aircraft at cruise
 * speed with an AI pilot that has no idea where it is meant to be. So it is
 * given a height to hold before anything else, told to land when the path was
 * drawn onto the ground, and — for a helicopter finishing a one-way route — has
 * its velocity taken off it so it settles rather than drifting on. Wargame does
 * the same three things, in the same order.
 *
 * Arguments:
 * 0: Path record <ARRAY>
 *
 * Return Value:
 * None
 *
 * Example:
 * [_record] call rtz_path_fnc_endFollow
 *
 * Public: No
 */

params ["_record"];

_record params ["_unit", "_hull", "_points", "", "_kind", "_patrol"];

// Before anything is allowed to decline. Safe on a dead, deleted or non-local
// unit, and a no-op on a path that never entered the puppet at all.
[_record, ""] call FUNC(setPuppet);

// Not guarded on locality, for the same reason FUNC(setPuppet) is not: on a
// machine that still owns the hull this releases it, and on one that has handed
// it over it does nothing, which is correct because everything being released
// was local state that did not travel with the vehicle either.
if ((_kind == KIND_AIR || {_kind == KIND_BOAT}) && {!isNull _hull}) then {
    if ((_record select FOLLOW_FLIGHT) isEqualTo []) then {
        // The AI executor's ceiling belongs to the VEHICLE, not to the order, so
        // it outlives the path unless it is taken off here — and a helicopter
        // left capped at approach speed never flies properly again for the rest
        // of the mission. The engine has no "remove the limit" value, which is
        // why the convention is a number no vehicle can reach.
        _hull limitSpeed SPEED_UNLIMITED;
    } else {
        if (_kind == KIND_AIR) then {
            (_record select FOLLOW_FLIGHT) params ["_isHeli"];

            private _final = ASLToAGL (_points select -1);
            private _alt = (_final select 2) max 0;

            // Hold the height the path ended at rather than whatever the AI last
            // had, or the aircraft climbs away from a carefully drawn approach
            // the moment it is released.
            _hull flyInHeight _alt;

            // A path drawn onto the ground was drawn as a landing. Told to the
            // AI rather than done by hand: it is the one part of the flight the
            // engine does far better than a velocity loop, and the reason the
            // scripted model is left rather than extended to cover it.
            if (_isHeli && {!_patrol} && {_alt <= FLIGHT_LAND_ALT}) then {
                _hull land "LAND";
            } else {
                // Otherwise take the scripted speed off it. Without this the
                // last velocity the model applied is still on the hull when the
                // AI takes over, and a helicopter finishes its route by sailing
                // on past the point it was drawn to stop at.
                if (_isHeli && {!_patrol}) then {
                    _hull setVelocity [0, 0, 0];
                };
            };
        };
    };
};

// Nothing to restore: the unit is gone, dead, or has moved to another machine.
// In the last case the new owner already has it under its own group's control —
// an order from here would do nothing anyway, silently.
if (isNull _unit || {!alive _unit} || {!local _unit}) exitWith {};

_unit doFollow (leader _unit);
