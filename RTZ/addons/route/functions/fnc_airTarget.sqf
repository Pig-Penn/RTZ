#include "script_component.hpp"
/*
 * Author: Maxim
 * Resolves the cursor into a candidate point for an AIRCRAFT route, where the
 * cursor alone cannot say what is meant: a screen position is two numbers and a
 * flight path needs three.
 *
 * So an aircraft route is drawn in two gestures. Plain dragging moves the path
 * horizontally at the altitude it already has — which is what makes it possible
 * to trace a route across a valley without the path diving into it. Dragging
 * with a modifier held moves it VERTICALLY instead, Alt for fine adjustment and
 * Shift for coarse, measured from how far the mouse travelled since the last
 * frame.
 *
 * Ground-relative altitude is deliberately NOT preserved: the height carried
 * forward is absolute, so a path drawn at 300 m stays at 300 m over a hill
 * rather than climbing it. AIR_MIN_ALT is the one exception — a path is never
 * allowed into the terrain, because an aircraft ordered into the dirt simply
 * refuses the order.
 *
 * The cursor is read through ZEN's helper with intersections OFF: an aircraft
 * path should follow the terrain the cursor is over, not jump onto the roof of
 * whatever building happens to be under it.
 *
 * Arguments:
 * 0: Route record <ARRAY>
 * 1: Mouse position on the previous frame <ARRAY>
 *
 * Return Value:
 * Candidate position, ASL <ARRAY>
 *
 * Example:
 * private _target = [_route, _lastMouse] call rtz_route_fnc_airTarget
 *
 * Public: No
 */

params ["_route", "_lastMouse"];

private _head = _route select ROUTE_HEAD;

GVAR(mods) params ["_shift", "", "_alt"];

if (_shift || {_alt}) exitWith {
    // Screen Y grows DOWNWARD, so the previous position minus the current one
    // is how far the mouse moved up — and up on screen must raise the path.
    private _delta = (_lastMouse select 1) - (getMousePosition select 1);
    private _rate = [ALT_RATE, ALT_RATE_FAST] select _shift;

    private _climbed = _head vectorAdd [0, 0, _delta * _rate];

    private _floor = (getTerrainHeightASL _climbed) + AIR_MIN_ALT;
    if ((_climbed select 2) < _floor) then {_climbed set [2, _floor]};

    _climbed
};

// Horizontal: the cursor's ground position, carrying the current altitude
private _ground = [nil, 0] call zen_common_fnc_getPosFromScreen;

private _target = [_ground select 0, _ground select 1, _head select 2];

private _floor = (getTerrainHeightASL _target) + AIR_MIN_ALT;
if ((_target select 2) < _floor) then {_target set [2, _floor]};

_target
