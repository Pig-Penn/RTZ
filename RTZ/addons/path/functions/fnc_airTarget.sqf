#include "script_component.hpp"
/*
 * Author: Maxim
 * Resolves the cursor into a candidate point for an AIRCRAFT path, where the
 * cursor alone cannot say what is meant: a screen position is two numbers and a
 * flight path needs three.
 *
 * So an aircraft path is drawn in two gestures. Plain dragging moves the path
 * horizontally at the altitude it already has — which is what makes it possible
 * to trace a path across a valley without the path diving into it. Dragging
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
 * 0: Path record <ARRAY>
 * 1: Mouse position on the previous frame <ARRAY>
 *
 * Return Value:
 * Candidate position, ASL <ARRAY>
 *
 * Example:
 * private _target = [_path, _lastMouse] call rtz_path_fnc_airTarget
 *
 * Public: No
 */

params ["_path", "_lastMouse"];

private _head = _path select PATH_HEAD;

GVAR(mods) params ["_shift", "", "_alt"];

if (_shift || {_alt}) exitWith {
    // Screen Y grows DOWNWARD, so the previous position minus the current one
    // is how far the mouse moved up — and up on screen must raise the path.
    private _delta = (_lastMouse select 1) - (getMousePosition select 1);
    private _rate = [ALT_RATE, ALT_RATE_FAST] select _shift;

    // ACCUMULATED across frames rather than measured fresh on each one, which is
    // the difference between fine altitude control working and doing nothing at
    // all.
    //
    // One frame of mouse travel is a small fraction of the screen — at ALT_RATE
    // a couple of metres — and FUNC(appendPoint) refuses any air sample under
    // AIR_CLIMB_SPACING. PATH_HEAD only moves when a sample is ACCEPTED, so a
    // per-frame delta measured against it is thrown away and re-measured from
    // the same head next frame: the two gates deadlock, and Alt (250 m per
    // screen) needs 0.024 screen-units inside a single frame to break out, which
    // no ordinary drag reaches. Shift only ever appeared to work because its
    // rate is four times coarser.
    //
    // The accumulator is what carries a drag across the frames it takes to earn
    // a point. FUNC(appendPoint) zeroes it when it spends one.
    //
    // Bounded by the SAME ceiling that function refuses a segment at. A frame
    // hitch mid-drag lands one enormous delta, and an accumulator past
    // MAX_SEGMENT is then refused on every frame after it while it can still
    // only grow — which wedges the altitude drag for the rest of the session.
    GVAR(altDrag) = ((GVAR(altDrag) + (_delta * _rate)) max (-MAX_SEGMENT)) min MAX_SEGMENT;

    private _climbed = _head vectorAdd [0, 0, GVAR(altDrag)];

    private _floor = (getTerrainHeightASL _climbed) + AIR_MIN_ALT;
    if ((_climbed select 2) < _floor) then {
        _climbed set [2, _floor];

        // The ACCUMULATOR is clamped with the point, not just the point. Left to
        // run it would bank however far the curator pushed down into the terrain
        // and make him drag all of it back up before the path rose at all.
        GVAR(altDrag) = _floor - (_head select 2);
    };

    _climbed
};

// The modifier is not held, so whatever vertical drag preceded this is over and
// its accumulator must not leak into the next one
GVAR(altDrag) = 0;

// Horizontal: the cursor's ground position, carrying the current altitude
private _ground = [nil, 0] call zen_common_fnc_getPosFromScreen;

private _target = [_ground select 0, _ground select 1, _head select 2];

private _floor = (getTerrainHeightASL _target) + AIR_MIN_ALT;
if ((_target select 2) < _floor) then {_target set [2, _floor]};

_target
