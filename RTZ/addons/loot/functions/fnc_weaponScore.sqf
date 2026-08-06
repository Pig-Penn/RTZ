#include "script_component.hpp"
/*
 * Author: Maxim
 * Scores one weapon for the loot planner: which slot it fills, how good it is, and
 * what it eats. Memoized in GVAR(scores) alongside FUNC(itemCategory)'s cache, since
 * the planner asks this of every weapon on every lootable for every unit.
 *
 * The score is one comparable NUMBER rather than a tuple, so the planner picks a
 * winner with a plain `>` instead of unrolling a three-way tiebreak at each
 * comparison. It is built from three tiers, each strictly dominating the next:
 *
 *   rank     a machine gun or sniper rifle outranks a rifle/SMG/shotgun, a guided
 *            missile launcher outranks an unguided rocket launcher (GVAR(ranks))
 *   muzzles  same category, more muzzles wins - this is what makes a grenadier's
 *            underbarrel-launcher variant beat the plain rifle it is otherwise
 *            identical to
 *   capacity same category and muzzle count, the bigger magazine wins
 *
 * The compatible magazine list rides along because the planner needs it anyway for
 * the ammunition gate, and pulling it here means one engine call per class per
 * session instead of one per comparison. That gate is the point of carrying it: a
 * "better" rifle the unit cannot feed is a downgrade, and taking it would leave him
 * standing in a field holding an empty gun.
 *
 * A class that fills no slot at all - a binocular, a vehicle weapon, a modded class
 * whose cursor resolves to nothing recognizable - scores slot -1 and is skipped by the
 * planner rather than special-cased at each call site.
 *
 * Arguments:
 * 0: Class <STRING>
 *
 * Return Value:
 * 0: Slot <NUMBER> - SLOT_PRIMARY, SLOT_LAUNCHER, SLOT_HANDGUN, or -1 for ineligible
 * 1: Kind <STRING> - the FUNC(itemCategory) kind, for the role check
 * 2: Score <NUMBER> - higher is better, comparable only within a slot
 * 3: Magazines <ARRAY of STRING> - every magazine the weapon accepts
 *
 * Example:
 * ([_weapon] call rtz_loot_fnc_weaponScore) params ["_slot", "_kind", "_score", "_mags"];
 *
 * Public: No
 */

params ["_class"];

if (_class isEqualTo "") exitWith {[-1, "", 0, []]};

private _key = toLowerANSI _class;
private _cached = GVAR(scores) get _key;

if (!isNil "_cached") exitWith {_cached};

([_class] call FUNC(itemCategory)) params ["_category", "_kind"];

private _entry = [-1, _kind, 0, []];

// Equipment, magazines and items never fill a weapon slot
if (_category isEqualTo "weapon") then {
    private _magazines = compatibleMagazines _class;

    // Carried even for a weapon that fills no slot. A binocular is never looted, but
    // the planner still has to ask whether a crate holds anything that feeds what the
    // unit is already carrying before it decides the walk is worth making
    _entry set [3, _magazines];

    // A kind absent from the rank table fills no slot: binoculars, rangefinders,
    // vehicle armament, and anything modded whose cursor resolves to none of the above
    private _rank = GVAR(ranks) get _kind;

    if (!isNil "_rank") then {
        _rank params ["_slot", "_tier"];

        // A single-muzzle weapon lists {"this"}, so the count is 1 either way; the max
        // floors a config that omits the entry entirely
        private _muzzles = (count (getArray (configFile >> "CfgWeapons" >> _class >> "muzzles"))) max 1;

        private _capacity = 0;

        {
            private _count = getNumber (configFile >> "CfgMagazines" >> _x >> "count");
            if (_count > _capacity) then {_capacity = _count};
        } forEach _magazines;

        // Tiers packed into one number, each strictly dominating the next. Capacity is
        // clamped so a mod shipping an absurd belt size cannot carry into the muzzle
        // tier and make a drum-fed rifle outrank a machine gun
        _entry set [0, _slot];
        _entry set [2, _tier * 1000000 + _muzzles * 1000 + (_capacity min 999)];
    };
};

GVAR(scores) set [_key, _entry];

_entry
