#include "script_component.hpp"
/*
 * Author: Maxim
 * Arrival hook of the loot errand: the unit is standing over his target, so work out
 * what is worth taking and hand the queue to FUNC(lootStep). SERVER - everything
 * downstream needs the unit local.
 *
 * The plan is built HERE rather than reused from the dispatch, even though
 * FUNC(lootSquads) already built one to decide the walk was worth making. Seconds
 * have passed: a co-claimant may have stripped the body, the unit may have been shot
 * and lost the vest that made a better one an upgrade, the crate may be empty. The
 * plan is cheap and every input to it has moved, so re-deriving it on the spot is
 * both simpler and more correct than carrying a stale one across the walk.
 *
 * An empty plan is a normal outcome, not a failure - it just means the target was
 * worth walking to when the order went out and is not worth taking from now.
 *
 * The errand token is snapshotted here, at the one moment it is known to be ours:
 * EFUNC(common,approach) only runs this hook if its own supersede guard passed, so
 * whatever the token reads now is this errand's. Every step down the queue compares
 * against it, which is what lets a curator re-task a unit mid-pickup and have the
 * abandoned queue fall silent instead of walking him back into formation on top of
 * his new order. Same contract rtz_repair's arrival hook works under.
 *
 * Arguments:
 * 0: Unit <OBJECT>
 * 1: Target <OBJECT> - corpse, weapon holder, crate or vehicle
 *
 * Return Value:
 * None
 *
 * Example:
 * [_unit, _target] call rtz_loot_fnc_lootTarget
 *
 * Public: No
 */

params ["_unit", "_target"];

if (!alive _unit) exitWith {};

// The target can be emptied and deleted by a co-claimant while this unit is still
// walking, so it is re-checked here rather than trusted from the dispatch
if (isNull _target) exitWith {
    [_unit] call FUNC(clearErrand);
};

private _plan = [_unit, _target] call FUNC(lootPlan);

if (_plan isEqualTo []) exitWith {
    [_unit] call FUNC(clearErrand);
};

// Settle on the spot and look at what he is picking up - approach resolves within a
// couple of meters, by which point he may still be walking
doStop _unit;
_unit doWatch _target;

[_unit, _target, _plan, 0, [_unit] call EFUNC(common,errandToken)] call FUNC(lootStep);
