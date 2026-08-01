#include "script_component.hpp"
/*
 * Author: Maxim
 * Inspects one group for the disassembled static weapons its members carry as
 * backpacks and returns the pieces needed to reassemble each of them.
 *
 * A weapon bag (assembleInfo primary = 1) names the static to build and the
 * support/tripod bags that must also be present; its carrier becomes the gunner and
 * one man carrying a matching support bag becomes the assistant. Single bag weapons
 * such as the Mk6 mortar need no assistant. Some modded configs invert the
 * reference, the support bag's base[] naming the weapon bag, so the assistant match
 * checks both directions (the same tolerance as LAMBS' deploy). All of it is
 * hashmap lookups against GVAR(bagInfo) - no config reads on the menu path.
 *
 * A group can carry more than one complete set (a weapons squad with two HMGs), so
 * every set is returned. Men are claimed greedily and never shared: each weapon bag
 * takes the nearest still-unclaimed matching carrier, so two sets in one squad pair
 * up with the two men actually standing next to their gunners.
 *
 * Carriers must be alive and on foot: assembling from inside a vehicle would
 * teleport the gunner out onto a static spawned next to (or inside) the vehicle.
 * A man whose QGVAR(assembling) claim has not lapsed is already building and is
 * skipped, so the context action can't offer an order FUNC(assembleWeapon)'s own
 * guard would only drop.
 *
 * Arguments:
 * 0: Group <GROUP>
 *
 * Return Value:
 * Assemble Sets <ARRAY of ARRAY> - one [gunner <OBJECT>, static class <STRING>,
 * assistant <OBJECT>] per complete set, [] when the group carries none. The
 * assistant is objNull when no second bag is required.
 *
 * Example:
 * [group _unit] call rtz_assemble_fnc_findAssembleSets
 *
 * Public: No
 */

params ["_group"];

private _sets = [];

if (isNull _group) exitWith {_sets};

// One pass over the group: every man who could take part, paired with his bag's
// cached data. Men in vehicles, the dead, the bagless and anyone already building
// drop out here, so neither loop below has to re-test them
private _carriers = [];
{
    if (alive _x && {isNull objectParent _x} && {CBA_missionTime >= (_x getVariable [QGVAR(assembling), 0])}) then {
        private _info = GVAR(bagInfo) getOrDefault [toLowerANSI backpack _x, []];

        if (_info isNotEqualTo []) then {
            _carriers pushBack [_x, _info select 0, _info select 1];
        };
    };
} forEach (units _group);

private _claimed = [];

{
    _x params ["_gunner", "_staticClass", "_requiredBags"];

    // An empty class means the bag builds nothing (a support bag, or a primary whose
    // assembleTo is missing) - it can only ever be somebody else's support. Already
    // claimed men belong to an earlier set
    if (_staticClass isNotEqualTo "" && {!(_gunner in _claimed)}) then {
        if (_requiredBags isEqualTo []) then {
            // Single bag weapon, the gunner assembles alone
            _claimed pushBack _gunner;
            _sets pushBack [_gunner, _staticClass, objNull];
        } else {
            // Nearest unclaimed groupmate whose bag satisfies this weapon, matched in
            // either direction. Linear scan rather than a sort: a handful of
            // candidates, and no throwaway pair array to allocate
            private _gunnerBag = backpack _gunner;
            private _assistant = objNull;
            private _closest = 1e10;

            {
                _x params ["_candidate", "", "_candidateBases"];

                if (_candidate != _gunner && {!(_candidate in _claimed)} && {
                    (backpack _candidate) in _requiredBags || {_gunnerBag in _candidateBases}
                }) then {
                    private _distance = _candidate distance _gunner;

                    if (_distance < _closest) then {
                        _closest = _distance;
                        _assistant = _candidate;
                    };
                };
            } forEach _carriers;

            if (!isNull _assistant) then {
                _claimed append [_gunner, _assistant];
                _sets pushBack [_gunner, _staticClass, _assistant];
            };
        };
    };
} forEach _carriers;

_sets
