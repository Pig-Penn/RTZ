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

private _probe = ASLToAGL (_head vectorAdd ((_head vectorFromTo _target) vectorMultiply (_distance * ROAD_SNAP_BIAS)));

private _road = [_probe, ROAD_SNAP_RADIUS] call BIS_fnc_nearestRoad;
if (isNull _road) exitWith {[_target, false]};

[(getPosASL _road) vectorAdd [0, 0, ROAD_LIFT], true]
