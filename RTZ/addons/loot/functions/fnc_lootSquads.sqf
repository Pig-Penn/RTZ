#include "script_component.hpp"
/*
 * Author: Maxim
 * SERVER handler body for QGVAR(loot) (registered in XEH_postInit). Orchestrates the
 * whole order: finds what is lootable around each selected squad, works out which
 * unit should go to which target, and walks them over. FUNC(lootTarget) takes it from
 * the moment each one arrives.
 *
 * doMove, the engine take actions and the inventory commands must all run where the
 * units are local - the server, for the Zeus AI this targets - so non-local units are
 * dropped here. The walk itself is the shared EFUNC(common,approach) engine:
 * unscheduled, with a distance-scaled timeout, so nothing pathfinds forever into an
 * unreachable target and the errand always resolves through FUNC(clearErrand).
 *
 * Targets are claimed ACROSS the whole order, not per group. Claiming per group -
 * which is what this used to do - let two selected squads independently decide the
 * same corpse was their nearest target and send men from both to fight over it. One
 * pool, one claim table, one cap.
 *
 * The cap is what spreads a squad out: with more units than targets everyone still
 * gets somewhere to go, and with targets to spare nobody piles on. Co-claimants ring
 * their shared target at an even share of the circle. A FIXED bearing, which this used
 * to use, silently put the fourth claimant back on the first one's spot the moment
 * scarce targets pushed the cap past three.
 *
 * Nothing is dispatched on "that target has something in it". Every candidate is run
 * through FUNC(lootPlan) for THAT unit first, and a unit is only sent to a target he
 * would actually take something from. The old behaviour marched squads fifty meters
 * to corpses whose only gear was a worse vest, because the scan filter and the taker
 * disagreed about what counted as loot. The search is bounded at PLAN_ATTEMPTS
 * candidates per unit so a body-strewn field cannot turn dispatch into a full
 * cross product.
 *
 * There is deliberately NO "already looting" claim variable on the unit. The errand
 * token EFUNC(common,approach) stamps already answers the same question and cannot
 * leak: a second order simply supersedes the first, and the abandoned queue falls
 * silent at its next token check. The flag this used to carry was set on dispatch and
 * cleared by the errand's own completion hooks - hooks that approach does not run
 * when it supersedes, so any unit the curator re-tasked mid-walk kept a permanently
 * true claim and could never be ordered to loot again for the rest of the mission.
 *
 * Arguments:
 * 0: Groups <ARRAY of GROUP>
 *
 * Return Value:
 * None
 *
 * Example:
 * [_groups] call rtz_loot_fnc_lootSquads
 *
 * Public: No
 */

params ["_groups"];

private _radius = GVAR(radius);

// One pool for the whole order. Parallel arrays rather than a map keyed by object:
// the list is short enough that `find` beats the hashing, and the claim count has to
// be indexed alongside it anyway
private _targets = [];
private _claims = [];

// Per group: the units that can go, and which pool entries are in reach of them
private _batches = [];

{
    private _group = _x;

    if (!isNull _group) then {
        // Dismounted, live, server-local AI
        private _units = (units _group) select {
            alive _x && {!isPlayer _x} && {local _x} && {isNull objectParent _x}
            && {lifeState _x isNotEqualTo "INCAPACITATED"}
        };

        if (_units isNotEqualTo []) then {
            private _lootables = [leader _group, _radius] call FUNC(collectLootables);

            if (_lootables isNotEqualTo []) then {
                private _indices = [];

                {
                    private _index = _targets find _x;

                    if (_index < 0) then {
                        _index = count _targets;
                        _targets pushBack _x;
                        _claims pushBack 0;
                    };

                    _indices pushBackUnique _index;
                } forEach _lootables;

                _batches pushBack [_units, _indices];
            };
        };
    };
} forEach _groups;

if (_batches isEqualTo []) exitWith {};

{
    _x params ["_units", "_indices"];

    // The cap is per SQUAD, against the targets that squad can actually reach, while
    // the counter it increments is the order-wide one. A single global cap would
    // starve the squad that has eight men and one body in reach on behalf of the one
    // with two men and twenty, and leave six of them standing around
    private _cap = (ceil (count _units / count _indices)) max 1;
    private _fan = 360 / _cap;

    {
        private _unit = _x;

        // Walk out from the nearest candidate with a free claim slot, stopping at the
        // first one this unit would actually take something from
        private _tried = [];
        private _target = objNull;
        private _slot = 0;
        private _attempts = 0;

        while {_attempts < PLAN_ATTEMPTS && {isNull _target}} do {
            _attempts = _attempts + 1;

            private _best = -1;
            private _bestDistance = 1e10;

            {
                if (!(_x in _tried) && {(_claims select _x) < _cap}) then {
                    private _distance = _unit distanceSqr (_targets select _x);

                    if (_distance < _bestDistance) then {
                        _bestDistance = _distance;
                        _best = _x;
                    };
                };
            } forEach _indices;

            if (_best < 0) then {
                // Nothing left within reach of this unit - stop looking
                _attempts = PLAN_ATTEMPTS;
            } else {
                _tried pushBack _best;

                private _candidate = _targets select _best;

                // The plan itself is thrown away - it is only asked for as the test of
                // whether this unit would take anything here. FUNC(lootTarget) builds a
                // fresh one on arrival, by which point every input to it has moved
                if (([_unit, _candidate] call FUNC(lootPlan)) isNotEqualTo []) then {
                    _target = _candidate;
                    _slot = _claims select _best;
                    _claims set [_best, _slot + 1];
                };
            };
        };

        if (!isNull _target) then {
            // Ring the approach points - own side first, then an even share of the
            // circle apart - so co-claimants do not jostle over the same spot
            private _position = _target getPos [APPROACH_DISTANCE, (_target getDir _unit) + _slot * _fan];

            [
                _unit,
                _position,
                ARRIVE_DISTANCE,
                WALK_TIMEOUT_BASE + (_unit distance2D _position) * WALK_TIMEOUT_PER_METER,
                LINKFUNC(lootTarget),
                LINKFUNC(clearErrand),
                [_unit, _target],
                true
            ] call EFUNC(common,approach);
        };
    } forEach _units;
} forEach _batches;
