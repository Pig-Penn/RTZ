#include "script_component.hpp"
/*
 * Author: Maxim
 * Whether a drawn path is a closed circuit — long enough to be a route, with its
 * far end back where it started — and therefore commits as a patrol that cycles
 * rather than a move that stops.
 *
 * One definition, three callers: FUNC(commitPaths) turning it into an order, and
 * both renderers, which close the loop on screen the moment it qualifies. That
 * shared use is the whole point of the function existing. Wargame decides the
 * same thing in two unrelated places — once at mouse-up to print "PATROL LOOP!",
 * and again inside the executor to set the flag — with the length threshold
 * spelled differently in each, so a curator can be told a circuit closed and
 * then be given a one-way move.
 *
 * The length floor matters as much as the closure test: without it every short
 * there-and-back scribble is a circuit, since its ends necessarily meet.
 *
 * Cheap enough to ask every frame per path, which is what the renderers do —
 * two counts and one distance2D, and no walk of the point list.
 *
 * Arguments:
 * 0: Points, ASL <ARRAY>
 *
 * Return Value:
 * The path is a closed circuit <BOOL>
 *
 * Example:
 * if ([_points] call rtz_path_fnc_isPatrol) then {...};
 *
 * Public: No
 */

params ["_points"];

if (count _points < PATROL_MIN_POINTS) exitWith {false};

// 2D on purpose. A flight plan that returns over its own start point a hundred
// metres higher is still a circuit — the aircraft flies the same ground track
// round again, which is what a patrol is.
(_points select 0) distance2D (_points select -1) <= PATROL_CLOSE_DIST
