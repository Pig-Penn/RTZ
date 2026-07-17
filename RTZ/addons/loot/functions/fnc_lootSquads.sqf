#include "script_component.hpp"
/*
 * Author: Maxim
 * SERVER handler body for QGVAR(loot) (registered in XEH_postInit). Orchestrates a
 * squad loot sweep: finds the lootables around each group's leader, assigns every
 * dismounted AI unit its own target (nearest-first, with a claimant cap per target so
 * the squad spreads out instead of mobbing one crate), walks it over, loots via
 * FUNC(lootTarget), and folds it back into formation.
 *
 * doMove / the engine actions / the loadout commands must run where the units are
 * local - the server, for the Zeus AI this targets - so non-local units are skipped.
 * The walk runs on the shared EFUNC(common,approach) engine: unscheduled, with a
 * distance-scaled timeout, so nothing pathfinds forever into an unreachable target
 * and the errand always resolves through FUNC(clearErrand). A per-unit QGVAR(looting)
 * claim makes repeated clicks re-entry-safe.
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

{
    private _group = _x;

    if (!isNull _group) then {
        // Dismounted, live, server-local AI not already on a loot errand
        private _units = (units _group) select {
            alive _x && {!isPlayer _x} && {local _x} && {isNull objectParent _x}
            && {lifeState _x isNotEqualTo "INCAPACITATED"}
            && {!(_x getVariable [QGVAR(looting), false])}
        };

        private _lootables = [];

        if (_units isNotEqualTo []) then {
            _lootables = [getPosATL leader _group, _radius] call FUNC(collectLootables);
        };

        if (_lootables isNotEqualTo []) then {
            // Cap the claimants per target so every unit gets one even where targets
            // are scarce, but nobody piles on while free targets remain
            private _claims = _lootables apply {0};
            private _cap = ceil (count _units / count _lootables);

            {
                private _unit = _x;

                // Nearest target with a free claim slot
                private _best = -1;
                private _bestDistance = 1e10;

                {
                    if (_claims select _forEachIndex < _cap) then {
                        private _distance = _unit distanceSqr _x;

                        if (_distance < _bestDistance) then {
                            _bestDistance = _distance;
                            _best = _forEachIndex;
                        };
                    };
                } forEach _lootables;

                if (_best > -1) then {
                    private _target = _lootables select _best;
                    private _slot = _claims select _best;
                    _claims set [_best, _slot + 1];

                    _unit setVariable [QGVAR(looting), true];

                    // Ring the approach points (own side first, then FAN_BEARING
                    // apart) so co-claimants don't jostle over the same spot
                    private _position = _target getPos [APPROACH_DISTANCE, (_target getDir _unit) + _slot * FAN_BEARING];

                    [
                        _unit,
                        _position,
                        ARRIVE_DISTANCE,
                        WALK_TIMEOUT_BASE + (_unit distance2D _position) * WALK_TIMEOUT_PER_METER,
                        {
                            params ["_unit", "_target"];

                            // The target can be emptied and deleted by a co-claimant
                            // while this unit is still walking
                            if (!isNull _target) then {
                                [_unit, _target] call FUNC(lootTarget);
                            };

                            [_unit] call FUNC(clearErrand);
                        },
                        LINKFUNC(clearErrand),
                        [_unit, _target],
                        true
                    ] call EFUNC(common,approach);
                };
            } forEach _units;
        };
    };
} forEach _groups;
