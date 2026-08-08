#include "script_component.hpp"
/*
 * Author: Maxim
 * Draws the rest of the selection's paths behind the one being traced, so a
 * column is one gesture instead of six. Wargame's best idea, and its most
 * tangled code.
 *
 * A trailing path IS the leader's path, ending a fixed distance short of it —
 * so followers walk the line the curator actually drew, in order, spaced out
 * along it.
 *
 * On the GROUND nothing is offset sideways: units that are meant to move in a
 * formation already do so through their group, and a hand-built lateral stagger
 * fights the AI's own formation keeping rather than adding to it.
 *
 * AIRCRAFT get the offset, because none of that is true of them. Nothing keeps
 * a flight in formation along a scripted chain of move orders, so one traced
 * line handed to four helicopters is not a column — it is four aircraft
 * converging on the same piece of air at four different speeds, the trailing
 * ones inside the leader's downwash. Each rank is therefore lifted by
 * AIR_STACK_ALT and stepped AIR_ECHELON_SIDE metres out from the line of
 * travel, alternating side by rank, which is what Wargame does and the reason
 * its flights arrive intact.
 *
 * An echelon point is DERIVED, not traced, so it never passed through
 * FUNC(validatePoint) and a left-hand offset above a valley wall would put a
 * helicopter inside the terrain. Every one is floored at AIR_MIN_ALT over the
 * ground beneath it — the same floor FUNC(airTarget) applies to a point the
 * curator drags there by hand.
 *
 * Only paths that have nothing of their own on them are recruited, and a path
 * stops trailing the moment its own handle is grabbed (FUNC(handleInput)). A
 * path somebody has drawn by hand is never overwritten.
 *
 * Kinds are not mixed. A helicopter trailing a rifleman's path by twelve metres
 * is not a formation, it is a crash.
 *
 * The leader's facing spans (PATH_FACING) are copied with the points, rebased
 * onto the follower's own index range — a squad told to advance covering a flank
 * covers it as a squad, not as one man and five who face wherever they are
 * going.
 *
 * Arguments:
 * 0: Path being traced <ARRAY>
 *
 * Return Value:
 * None
 *
 * Example:
 * [_path] call rtz_path_fnc_formationTrail
 *
 * Public: No
 */

params ["_leader"];

_leader params ["_leadUnit", "", "_leadPoints", "", "_leadKind"];
private _leadFacing = _leader select PATH_FACING;

private _total = count _leadPoints;
if (_total == 0) exitWith {};

private _profile = GVAR(profiles) select _leadKind;

// The gap is authored in metres and applied in points, which is the unit the
// leader's path is actually made of
private _gap = (round ((_profile select PROF_FORMATION_GAP) / (_profile select PROF_SPACING))) max 1;

private _rank = 0;

{
    private _path = _x;

    if ((_path select PATH_UNIT) isEqualTo _leadUnit) then {continue};
    if ((_path select PATH_KIND) != _leadKind) then {continue};

    // Rank is claimed by POSITION in the selection, BEFORE eligibility is
    // considered, so it is fixed for the whole session.
    //
    // Counting only the paths still being trailed renumbers every follower
    // behind one the curator takes over by hand. On the ground that is a change
    // of spacing; for a flight it moves the echelon to the other side of the
    // line and drops it a rank's worth of altitude, so the points already drawn
    // for that aircraft and the ones about to be belong to two different
    // formations — and the path it flies steps sideways at the join.
    _rank = _rank + 1;

    private _points = _path select PATH_POINTS;

    // Eligible if it is already trailing this leader, or if it is untouched.
    // Anything else belongs to the curator.
    private _trailing = (_path select PATH_LEADER) isEqualTo _leadUnit;
    if (!_trailing && {_points isNotEqualTo []}) then {continue};

    // How much of the leader's path this follower has earned so far
    private _take = _total - (_rank * _gap);
    if (_take <= 0) then {continue};

    private _have = count _points;
    if (_have >= _take) then {continue};

    if (_leadKind == KIND_AIR) then {
        // Rank 1 goes right, rank 2 left, rank 3 right again — so the flight
        // spreads either side of the traced line instead of drifting off one
        // shoulder of it.
        private _side = [270, 90] select (_rank % 2);
        private _out = AIR_ECHELON_SIDE * _rank;
        private _up = AIR_STACK_ALT * _rank;

        for "_i" from _have to (_take - 1) do {
            private _p = _leadPoints select _i;

            // Heading of the leg this point ends, so the offset is square to the
            // line of travel rather than to a compass. The first point has no
            // preceding one to measure from and takes the second leg's heading.
            private _prev = _leadPoints select ((_i - 1) max 0);
            private _next = _leadPoints select ((_i + 1) min (_total - 1));
            private _heading = _prev getDir _next;

            // getPos works in AGL and would re-plant the point on the ground,
            // so the offset is applied as a flat vector in the space the point
            // is already in.
            private _bearing = _heading + _side;
            private _offset = _p vectorAdd [
                (sin _bearing) * _out,
                (cos _bearing) * _out,
                _up
            ];

            // Derived, so never validated — hold it clear of whatever is now
            // underneath it
            private _floor = (getTerrainHeightASL _offset) + AIR_MIN_ALT;
            if ((_offset select 2) < _floor) then {_offset set [2, _floor]};

            _points pushBack _offset;
        };
    } else {
        for "_i" from _have to (_take - 1) do {
            _points pushBack (_leadPoints select _i);
        };
    };

    // Spans are copied whole rather than sliced: a follower's path is a PREFIX
    // of the leader's, so every span that starts inside it starts at the same
    // index, and the ones past its end are simply never reached.
    //
    // Compared before copying because this function runs on every point the
    // leader accepts, and a deep copy per follower per point — for a list that
    // changes when the curator presses a key — is work paid hundreds of times to
    // produce the same handful of pairs. The lists are pairs of numbers, so the
    // comparison that skips it is cheaper than the copy it skips.
    if (_leadFacing isNotEqualTo (_path select PATH_FACING)) then {
        _path set [PATH_FACING, +_leadFacing];
    };

    _path set [PATH_LEADER, _leadUnit];

    private _last = _points select -1;
    private _prior = if (count _points > 1) then {_points select -2} else {getPosASL (_path select PATH_HULL)};

    _path set [PATH_DIR, _prior getDir _last];
    _path set [PATH_HEAD, _last];

    if (_leadKind == KIND_AIR) then {
        _path set [PATH_ALT, format ["%1 m", round ((ASLToAGL _last) select 2)]];
    };
} forEach GVAR(paths);
