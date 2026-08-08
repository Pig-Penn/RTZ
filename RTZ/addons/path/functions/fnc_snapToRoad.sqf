#include "script_component.hpp"
/*
 * Author: Maxim
 * Pulls a candidate point onto the nearest road, for tracing convoy paths.
 * Freehand tracing of a winding road produces a line that clips every verge;
 * this is what makes a road path drawable at all.
 *
 * The search is biased FORWARD along the direction of travel rather than run
 * from the cursor itself. Searching from where the cursor is keeps finding the
 * piece of road already under the handle, which snaps every sample back onto the
 * point it started from and the path never advances. Wargame biases the same
 * way, for the same reason.
 *
 * A snapped point also reports itself as snapped, because the caller has to
 * relax its climb and incline gates for it: roads legitimately run up gradients
 * that would be rejected as a wall if traced across open ground.
 *
 * The answer is a point ON the road, not the road SEGMENT's origin. A segment is
 * ten to twenty-five metres long, so every sample taken inside one resolves to
 * the same position — which the caller's spacing gate then refuses until the
 * forward bias has walked the probe onto the next segment entirely. The path
 * comes out as a row of dots one segment apart with straight lines between them,
 * which on a curve is a line that leaves the road. Projecting the probe onto the
 * segment costs one dot product and gives back the continuous line the gesture
 * was drawing.
 *
 * Arguments:
 * 0: Candidate position, ASL <ARRAY>
 * 1: Current path head, ASL <ARRAY>
 *
 * Return Value:
 * 0: Position to use, ASL <ARRAY>
 * 1: It was snapped to a road <BOOL>
 *
 * Example:
 * ([_target, _head] call rtz_path_fnc_snapToRoad) params ["_target", "_snapped"]
 *
 * Public: No
 */

params ["_target", "_head"];

private _distance = _head distance _target;

// The cursor has left the road being followed entirely; snapping now would
// teleport the path sideways onto whatever else is nearby
if (_distance > ROAD_SNAP_MAX) exitWith {[_target, false]};

private _biased = _head vectorAdd ((_head vectorFromTo _target) vectorMultiply (_distance * ROAD_SNAP_BIAS));

private _road = [ASLToAGL _biased, ROAD_SNAP_RADIUS] call BIS_fnc_nearestRoad;
if (isNull _road) exitWith {[_target, false]};

// The segment's own endpoints. Everything else about a road — its width, its
// texture, whether it is a bridge — is in here too, and none of it is wanted;
// these two are, because they are the LINE the point has to land on.
(getRoadInfo _road) params ["", "", "", "", "", "", "_begin", "_end"];

// Where along the segment the probe falls, clamped to its ends so a probe past
// the last piece of road lands on the end of it rather than out on the
// extension of its centreline. Measured in the ground plane: road segments have
// height, and including it would pull the point along the gradient rather than
// along the road.
private _run = [0, 0, 0];
private _lengthSq = 0;

if (!isNil "_begin" && {!isNil "_end"}) then {
    _run = _end vectorDiff _begin;
    _lengthSq = ((_run select 0) ^ 2) + ((_run select 1) ^ 2);
};

// A segment with no ground-plane geometry to project onto is what an object
// that is not really a road piece answers, and what everything answered before
// getRoadInfo carried endpoints. Falling back to the origin is the old
// behaviour: steppy, but never wrong.
if (_lengthSq <= 0) exitWith {
    [(getPosASL _road) vectorAdd [0, 0, ROAD_LIFT], true]
};

private _from = _biased vectorDiff _begin;
private _along = ((((_from select 0) * (_run select 0)) + ((_from select 1) * (_run select 1))) / _lengthSq) max 0 min 1;

// Roads sit fractionally below their own surface, so the point is lifted clear
// or the caller's line test hits the road it was just placed on.
[(_begin vectorAdd (_run vectorMultiply _along)) vectorAdd [0, 0, ROAD_LIFT], true]
