#include "script_component.hpp"
/*
 * Author: Maxim
 * Carries out ONE step of a FUNC(lootPlan) and chains itself to the next. SERVER -
 * the engine take actions and the inventory commands both need the unit local.
 *
 * The queue exists because engine take actions cannot be stacked. This component used
 * to fire two "TakeWeapon" actions and a "rearm" into the same frame; they are
 * ANIMATED actions, so the engine honoured roughly one of them, and "rearm" - which
 * tops up magazines for the weapons a unit is HOLDING - resolved before the new
 * weapon was anywhere near his hands. That is why the rearm step is always last and
 * why nothing else runs until the step before it has actually landed.
 *
 * Steps come in two shapes:
 *
 *   ACTION steps (weapon, launcher, item, rearm) hand the work to the engine so the
 *   pickup animates, then wait on the RESULT - is the weapon actually in the slot -
 *   rather than on a fixed delay. A quick pickup chains on the next frame; a stuck
 *   one falls through after STEP_TIMEOUT and FUNC(forceTake) applies the transfer
 *   directly instead. That fallback is deliberate belt-and-braces: whether an AI can
 *   be made to take a weapon off a BODY with an action, rather than out of the weapon
 *   holder beside it, is inconsistent enough that LAMBS routes around it entirely.
 *   This way the loot lands either way and the animation is a bonus, not a dependency.
 *
 *   DIRECT steps (backpack, vest, headgear, nvg) have no engine action behind them -
 *   there is no "wear this vest" the way there is a "take this rifle" - so they go
 *   straight through FUNC(forceTake) under a gear animation and simply dwell long
 *   enough for it to read.
 *
 * Every step re-checks the three ways an errand can stop being valid: the unit died,
 * the curator re-tasked him, or the target was emptied and deleted by a co-claimant
 * while he was still walking. Re-tasking is the one that must NOT release him -
 * a newer order owns him by then and rejoining formation on top of it would cancel it.
 *
 * Arguments:
 * 0: Unit <OBJECT>
 * 1: Target <OBJECT>
 * 2: Plan <ARRAY> - from FUNC(lootPlan)
 * 3: Index <NUMBER> - step to run
 * 4: Errand Token <NUMBER> - the unit's EFUNC(common,errandToken) when the walk began
 *
 * Return Value:
 * None
 *
 * Example:
 * [_unit, _target, _plan, 0, _token] call rtz_loot_fnc_lootStep
 *
 * Public: No
 */

params ["_unit", "_target", "_plan", "_index", "_token"];

// Re-tasked mid-queue: the new order owns him, so drop the errand WITHOUT releasing
// him - doing so would walk him back into formation on top of whatever he was just
// told to do
if (([_unit] call EFUNC(common,errandToken)) != _token) exitWith {};

if (
    !alive _unit
    || {_index >= count _plan}
    || {isNull _target}
    || {_unit distance _target > TARGET_ABORT_DISTANCE}
) exitWith {
    [_unit] call FUNC(clearErrand);
};

(_plan select _index) params ["_kind", "_class"];

private _next = [_unit, _target, _plan, _index + 1, _token];
private _immediate = true;
private _verify = {};

switch (_kind) do {
    case "weapon": {
        _immediate = false;
        _unit action ["TakeWeapon", _target, _class];
        _verify = {primaryWeapon (_this select 0) isEqualTo (_this select 1)};
    };

    case "launcher": {
        _immediate = false;
        _unit action ["TakeWeapon", _target, _class];
        _verify = {secondaryWeapon (_this select 0) isEqualTo (_this select 1)};
    };

    case "item": {
        _immediate = false;
        _unit action ["TakeItem", _target, _class];
        _verify = {
            params ["_unit", "_class"];

            _class in (items _unit) || {_class in (assignedItems _unit)}
        };
    };

    // The engine reports nothing back from a rearm, and picking the magazine list
    // apart to guess whether it did anything is not worth the complexity - it is the
    // last step either way, so a dwell for the animation is all it needs
    case "rearm": {
        _unit action ["rearm", _target];
    };

    // Worn gear: no engine action exists, so it is applied outright
    default {
        _unit playActionNow "Gear";

        [_unit, _target, _kind, _class] call FUNC(forceTake);
    };
};

if (_immediate) exitWith {
    [LINKFUNC(lootStep), _next, STEP_DWELL] call CBA_fnc_waitAndExecute;
};

// The wait carries THIS step's index, not the next one - the timeout branch has to
// look the step back up before it can apply the transfer by hand
[
    {
        params ["_unit", "", "", "", "_token", "_verify", "_class"];

        !alive _unit
        || {([_unit] call EFUNC(common,errandToken)) != _token}
        || {[_unit, _class] call _verify}
    },
    {
        params ["_unit", "_target", "_plan", "_index", "_token"];

        [_unit, _target, _plan, _index + 1, _token] call FUNC(lootStep);
    },
    [_unit, _target, _plan, _index, _token, _verify, _class],
    STEP_TIMEOUT,
    {
        params ["_unit", "_target", "_plan", "_index", "_token", "_verify", "_class"];

        // The engine never honoured the action. Apply the transfer directly rather
        // than let the queue stall on it, then carry on down the plan
        if (alive _unit && {!isNull _target} && {!([_unit, _class] call _verify)}) then {
            [_unit, _target, (_plan select _index) select 0, _class] call FUNC(forceTake);
        };

        [_unit, _target, _plan, _index + 1, _token] call FUNC(lootStep);
    }
] call CBA_fnc_waitUntilAndExecute;
