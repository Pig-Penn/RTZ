#include "script_component.hpp"
/*
 * Author: Maxim
 * Resamples a drawn route down to what the executor can actually use, keeping
 * its corners.
 *
 * A route is drawn dense and executed sparse. The fine sampling exists so the
 * line on screen is the line that was traced; the executor hands each leg to the
 * AI's own navigation, which has no use for a target three metres ahead — and
 * every one of those points would otherwise be copied across the network at
 * commit, per unit. A 400-point infantry route typically leaves here as thirty
 * or forty.
 *
 * Two things earn a point its place: distance, so legs do not grow unbounded on
 * a straight run, and TURN, so a corner survives however close it sits to the
 * point before it. Distance alone would round off exactly the corners a curator
 * drew deliberately — which is the whole reason this is not a plain "keep every
 * Nth point".
 *
 * Arguments:
 * 0: Points, ASL <ARRAY>
 * 1: Minimum distance between kept points <NUMBER>
 *
 * Return Value:
 * Reduced points, ASL; always ends on the original final point <ARRAY>
 *
 * Example:
 * private _legs = [_points, 20] call rtz_route_fnc_reducePath
 *
 * Public: No
 */

params ["_points", "_spacing"];

private _count = count _points;
if (_count < 3) exitWith {+_points};

private _first = _points select 0;
private _kept = [_first];

private _lastKept = _first;
// Heading that arrived at the last kept point. Seeded from the first leg so the
// opening segment is never mistaken for a turn.
private _lastDir = _first getDir (_points select 1);

// The final point is appended unconditionally below, so the scan stops short of
// it — a route must end where it was drawn to end, whatever the resampling says.
private _last = _count - 1;

for "_i" from 1 to (_last - 1) do {
    private _p = _points select _i;
    private _dir = _lastKept getDir _p;

    // Signed difference folded into -180..180, then measured. Without the fold a
    // turn across north reads as 350 degrees rather than 10.
    private _turn = abs ((((_dir - _lastDir) + 540) % 360) - 180);

    if (_lastKept distance _p >= _spacing || {_turn >= COMMIT_ANGLE}) then {
        _kept pushBack _p;
        _lastKept = _p;
        _lastDir = _dir;
    };
};

_kept pushBack (_points select -1);

_kept
