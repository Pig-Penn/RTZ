#include "script_component.hpp"
/*
 * Author: Maxim
 * Moves one thing from a target into a unit with plain inventory commands, no engine
 * action and no animation of its own. Runs where the UNIT is local, which
 * FUNC(lootSquads) guarantees by filtering on it.
 *
 * The TARGET is a separate question and must not be assumed to share that machine:
 * bodies of AI owned by a headless client or by a player-led group are local
 * elsewhere. Where a *Global command exists (weapons, backpacks, and every cargo
 * container) it is used and locality is a non-issue. The worn slots have no such
 * variant — `removeVest`, `removeHeadgear` and `removeItem` are argument- AND
 * effect-local — so those strips are routed to the body's owner through
 * FUNC(stripWorn). Doing them inline duplicated the item: the looter gained it and
 * the corpse kept its copy.
 *
 * Two callers, for two different reasons. The worn-gear steps use it because there IS
 * no engine action to wear a vest or a helmet - it is the only way that step can
 * happen at all. The weapon and item steps use it as a FALLBACK, after the engine
 * declined to honour their take action inside STEP_TIMEOUT, so a loot errand cannot
 * come home empty just because the animation path was unreliable for that particular
 * container.
 *
 * The corpse and container branches exist because the two hold things differently: a
 * body WEARS its gear and answers the remove* commands, while a crate, weapon holder
 * or vehicle holds cargo, where an add*CargoGlobal of -1 is the engine's idiom for
 * taking a single entry back out.
 *
 * Backpack and vest contents are carried across rather than dropped, so a squad
 * picking assault packs off the dead inherits what was in them instead of a row of
 * empty bags. Adding a weapon or a vest a unit already has replaces what is there,
 * which is exactly what an upgrade step wants.
 *
 * Arguments:
 * 0: Unit <OBJECT>
 * 1: Target <OBJECT>
 * 2: Kind <STRING> - the FUNC(lootPlan) step kind
 * 3: Class <STRING>
 *
 * Return Value:
 * None
 *
 * Example:
 * [_unit, _body, "vest", "V_PlateCarrier1_rgr"] call rtz_loot_fnc_forceTake
 *
 * Public: No
 */

params ["_unit", "_target", "_kind", "_class"];

if (!alive _unit || {isNull _target} || {_class isEqualTo ""}) exitWith {};

private _isBody = _target isKindOf "CAManBase";

switch (_kind) do {
    case "weapon";
    case "launcher";
    case "handgun": {
        if (_isBody) then {
            _target removeWeaponGlobal _class;
        } else {
            _target addWeaponCargoGlobal [_class, -1];
        };

        _unit addWeaponGlobal _class;
    };

    case "backpack": {
        private _contents = if (_isBody) then {backpackItems _target} else {[]};

        if (_isBody) then {
            removeBackpackGlobal _target;
        } else {
            _target addBackpackCargoGlobal [_class, -1];
        };

        _unit addBackpackGlobal _class;

        {
            _unit addItemToBackpack _x;
        } forEach _contents;
    };

    // Vest and headgear are only ever planned against a body, which is the only thing
    // that wears them - a crate holds them as item cargo with no slot to take from
    case "vest": {
        // Read the contents BEFORE dispatching the strip - the strip may land on
        // another machine a frame later, and this has to see the body still dressed
        private _contents = vestItems _target;

        [QGVAR(strip), [_target, "vest", _class], _target] call CBA_fnc_targetEvent;
        _unit addVest _class;

        {
            _unit addItemToVest _x;
        } forEach _contents;
    };

    case "headgear": {
        [QGVAR(strip), [_target, "headgear", _class], _target] call CBA_fnc_targetEvent;
        _unit addHeadgear _class;
    };

    // Linked rather than carried: night vision dropped into the inventory is dead
    // weight, and the head slot is what the AI actually sees through
    case "nvg": {
        if (_isBody) then {
            [QGVAR(strip), [_target, "item", _class], _target] call CBA_fnc_targetEvent;
        } else {
            _target addItemCargoGlobal [_class, -1];
        };

        _unit linkItem _class;
    };

    case "item": {
        if (_isBody) then {
            [QGVAR(strip), [_target, "item", _class], _target] call CBA_fnc_targetEvent;
        } else {
            _target addItemCargoGlobal [_class, -1];
        };

        _unit addItem _class;
    };
};
