#include "script_component.hpp"
/*
 * rtz_fnc_lootNearbyApply
 *
 * SERVER handler body for QGVAR(lootNearbyApply) (registered in XEH_postInit).
 * Orchestrates a squad loot sweep: finds lootables around each group's leader,
 * assigns each dismounted AI unit its own target (nearest-first, capped
 * claimants per target so the squad spreads out instead of mobbing one crate),
 * walks the unit over, loots via FUNC(lootFromTarget), and folds the unit back
 * into formation. doMove / action / loadout commands must run where the units
 * are local — the server, for AI in Zeus PvP; non-local units are skipped.
 *
 * Fully unscheduled: the walk is watched by CBA_fnc_waitUntilAndExecute with a
 * distance-scaled timeout, so there is no spawn/sleep and nothing pathfinds
 * forever into a wreck. A per-unit QGVAR(looting) flag makes repeated clicks
 * re-entry-safe, and lambs_danger_forceMove (inert without LAMBS) keeps the
 * danger FSM from seizing the unit mid-errand.
 *
 * Parameters:
 *   0: Array — groups to sweep
 */

params ["_grps"];

private _radius = GVAR(lootRadius);

{
    private _grp = _x;
    if (!isNull _grp) then {
        // Dismounted, live, server-local AI not already on a loot errand.
        private _lootUnits = (units _grp) select {
            alive _x && {!isPlayer _x} && {local _x} && {isNull objectParent _x}
            && {lifeState _x isNotEqualTo "INCAPACITATED"}
            && {!(_x getVariable [QGVAR(looting), false])}
        };
        private _loot = if (_lootUnits isEqualTo []) then { [] } else {
            [getPosATL leader _grp, _radius] call FUNC(collectLootables)
        };

        if (_loot isNotEqualTo []) then {
            // Cap claimants per target so every unit gets one even when targets
            // are scarce, but nobody piles on while free targets remain.
            private _claims = _loot apply { 0 };
            private _cap = ceil (count _lootUnits / count _loot);

            {
                private _unit = _x;

                // Nearest target with a free claim slot.
                private _best = -1;
                private _bestDist = 1e10;
                {
                    if (_claims select _forEachIndex < _cap) then {
                        private _d = _unit distanceSqr _x;
                        if (_d < _bestDist) then { _bestDist = _d; _best = _forEachIndex; };
                    };
                } forEach _loot;

                if (_best > -1) then {
                    private _target = _loot select _best;
                    private _slot = _claims select _best;
                    _claims set [_best, _slot + 1];

                    _unit setVariable [QGVAR(looting), true];
                    _unit setVariable ["lambs_danger_forceMove", true];
                    _unit setUnitPosWeak "UP";

                    // Ring the approach points (own side first, then 120° apart)
                    // so co-claimants don't jostle over the same spot.
                    _unit doMove (_target getPos [1.2, (_target getDir _unit) + _slot * 120]);

                    [
                        {
                            params ["_unit", "_target"];
                            !alive _unit || {isNull _target} || {_unit distance2D _target < 3}
                        },
                        {
                            params ["_unit", "_target"];
                            if (alive _unit && {!isNull _target}) then {
                                [_unit, _target] call FUNC(lootFromTarget);
                            };
                            _unit setVariable [QGVAR(looting), nil];
                            _unit setVariable ["lambs_danger_forceMove", nil];
                            if (alive _unit) then {
                                _unit setUnitPosWeak "AUTO";
                                _unit doFollow leader _unit;
                            };
                        },
                        [_unit, _target],
                        12 + (_unit distance2D _target) * 0.5,
                        {
                            // Timeout: abandon the errand and rejoin formation.
                            params ["_unit"];
                            _unit setVariable [QGVAR(looting), nil];
                            _unit setVariable ["lambs_danger_forceMove", nil];
                            if (alive _unit) then {
                                _unit setUnitPosWeak "AUTO";
                                _unit doFollow leader _unit;
                            };
                        }
                    ] call CBA_fnc_waitUntilAndExecute;
                };
            } forEach _lootUnits;
        };
    };
} forEach _grps;
