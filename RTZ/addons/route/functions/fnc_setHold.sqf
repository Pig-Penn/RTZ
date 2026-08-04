#include "script_component.hpp"
/*
 * Author: Maxim
 * Holds a unit still for the duration of a planning session, or releases it.
 * Must run where the unit is local — AI orders have no effect anywhere else, and
 * fail silently rather than erroring (Gotchas §4).
 *
 * doStop rather than Wargame's disableAI "PATH". Two reasons, and both matter:
 * disabling PATH would make FUNC(routeKind) reject the very units this froze, so
 * a frozen selection could never be committed; and doStop is what the executor
 * issues first in any case, so a held unit that then receives a route transitions
 * without a release-and-re-stop in between.
 *
 * The release is doFollow, which is also how a unit is returned to formation
 * after a route finishes. Worth knowing: this will also release a unit that
 * something ELSE had stopped — a LAMBS garrison, most likely — if that unit
 * happened to be in a planning session. The hold is opt-in and off by default
 * partly for this reason.
 *
 * Arguments:
 * 0: Unit <OBJECT>
 * 1: Hold, or release <BOOL>
 *
 * Return Value:
 * None
 *
 * Example:
 * [_unit, true] call rtz_route_fnc_setHold
 *
 * Public: No
 */

params ["_unit", "_hold"];

if (isNull _unit || {!local _unit} || {!alive _unit}) exitWith {};

if (_hold) exitWith {
    doStop _unit;
};

_unit doFollow (leader _unit);
