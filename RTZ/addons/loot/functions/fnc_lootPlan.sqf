#include "script_component.hpp"
/*
 * Author: Maxim
 * Decides what ONE unit would take from ONE target, as an ordered list of steps.
 * Pure - it reads state and returns a plan, it never touches anybody's inventory.
 * FUNC(lootStep) is what carries the plan out.
 *
 * Being pure and cheap enough to run BEFORE dispatch is the whole point. The old
 * design asked only "does this thing have anything in it" and sent a unit walking on
 * that answer, so a squad could be marched fifty meters to a corpse whose only gear
 * was a worse vest, stand over it, and take nothing. Here an empty plan simply means
 * that unit is never sent, and FUNC(lootSquads) tries the next target instead.
 *
 * The rules, in the order the steps are emitted:
 *
 *   primary    empty slot takes the best the unit's ROLE is issued, falling back to
 *              anything rather than leaving him unarmed; an occupied slot only ever
 *              swaps WITHIN its own category, so a rifleman upgrades rifle to rifle
 *              and walks straight past a dropped sniper rifle. A role issued no
 *              primary at all - pilots, vehicle crew - is left alone rather than
 *              handed the first rifle going
 *   launcher   role-gated outright - a rifleman never picks one up - but once the
 *              role carries one, upgrades ACROSS categories, because rocket to
 *              missile is exactly the improvement the rank exists to express
 *   backpack   empty slot only, biggest capacity available
 *   vest       corpse only, by chest armor
 *   headgear   corpse only, by head armor. The number, not the old binary "is it in
 *              the armored list" test, which compared against a variable that does
 *              not exist
 *   items      role-gated: everyone tops up a first aid kit and night vision, medics
 *              take a medikit, engineers a toolkit, EOD a mine detector
 *   rearm      last, always, whenever anything above was taken or the target holds
 *              magazines the unit's own weapons can use
 *
 * Filling an EMPTY slot is always allowed; upgrading an occupied one is what
 * GVAR(upgradeGear) gates. A unit is never left worse off by turning that setting off.
 *
 * Every weapon is gated on ammunition: it is only taken if the unit already carries a
 * compatible magazine or the same target holds one. An upgrade the unit cannot feed
 * is a downgrade, and this is the one thing that stops a sweep handing a squad better
 * rifles and no way to fire them.
 *
 * Arguments:
 * 0: Unit <OBJECT>
 * 1: Target <OBJECT> - corpse, weapon holder, crate or vehicle
 *
 * Return Value:
 * Ordered steps, empty when there is nothing here for this unit <ARRAY of ARRAY>
 *   each step: 0: Kind <STRING>, 1: Class <STRING>
 *
 * Example:
 * private _plan = [_unit, _target] call rtz_loot_fnc_lootPlan;
 *
 * Public: No
 */

params ["_unit", "_target"];

if (isNull _unit || {isNull _target} || {!alive _unit}) exitWith {[]};

private _isBody = _target isKindOf "CAManBase";

// A corpse wears its gear; everything else holds it as cargo. The unprefixed cargo
// commands return the flat class list, where the get-prefixed ones build a second
// array of counts nobody here reads
private _weapons = if (_isBody) then {weapons _target} else {weaponCargo _target};
private _offered = if (_isBody) then {magazines _target} else {magazineCargo _target};
private _items = if (_isBody) then {items _target} else {itemCargo _target};
private _bags = if (_isBody) then {[backpack _target] - [""]} else {backpackCargo _target};

([_unit] call FUNC(unitRole)) params ["_roleKinds", "_roleLauncher", "_medic", "_engineer", "_eod"];

private _upgrade = GVAR(upgradeGear);
private _carried = magazines _unit;
private _plan = [];

// A weapon is only worth taking if it can be fed - from what the unit already carries
// or from this same target, which the terminal rearm step will strip
private _fnc_canFeed = {
    params ["_magazines"];

    _magazines isNotEqualTo []
    && {(_carried findIf {_x in _magazines} > -1) || {_offered findIf {_x in _magazines} > -1}}
};

// Best weapon on offer for one slot, or "" for none worth taking. _kinds restricts
// the search by category; an empty _kinds means anything that fills the slot
private _fnc_bestWeapon = {
    params ["_slot", "_kinds", "_beat"];

    private _best = "";
    private _bestScore = _beat;

    {
        ([_x] call FUNC(weaponScore)) params ["_candidateSlot", "_kind", "_score", "_magazines"];

        if (
            _candidateSlot isEqualTo _slot
            && {_score > _bestScore}
            && {_kinds isEqualTo [] || {_kind in _kinds}}
            && {[_magazines] call _fnc_canFeed}
        ) then {
            _best = _x;
            _bestScore = _score;
        };
    } forEach _weapons;

    _best
};

if (_weapons isNotEqualTo []) then {
    // --- primary ---
    private _current = primaryWeapon _unit;

    // An empty list means the role carries no primary AT ALL - a pilot, a crewman, a
    // civilian - and that is a reason to leave the slot alone, not a licence to fill
    // it with anything going. They are issued a sidearm and are not short of a weapon
    if (_current isEqualTo "") then {
        if (_roleKinds isNotEqualTo []) then {
            // Role first, then anything. A disarmed rifleman standing over a machine
            // gun picks the machine gun up rather than walking home empty-handed for
            // the sake of a tidy roster
            private _best = [SLOT_PRIMARY, _roleKinds, -1] call _fnc_bestWeapon;

            if (_best isEqualTo "") then {
                _best = [SLOT_PRIMARY, [], -1] call _fnc_bestWeapon;
            };

            if (_best isNotEqualTo "") then {
                _plan pushBack ["weapon", _best];
            };
        };
    } else {
        if (_upgrade) then {
            ([_current] call FUNC(weaponScore)) params ["", "_currentKind", "_currentScore"];

            private _best = [SLOT_PRIMARY, [_currentKind], _currentScore] call _fnc_bestWeapon;

            if (_best isNotEqualTo "") then {
                _plan pushBack ["weapon", _best];
            };
        };
    };

    // --- launcher ---
    // Gated on the role carrying one at all, in BOTH directions: a rifleman never
    // takes one, and a launcher-carrying role upgrades freely across categories
    if (_roleLauncher) then {
        private _current = secondaryWeapon _unit;

        if (_current isEqualTo "" || {_upgrade}) then {
            private _score = if (_current isEqualTo "") then {
                -1
            } else {
                ([_current] call FUNC(weaponScore)) select 2
            };

            private _best = [SLOT_LAUNCHER, [], _score] call _fnc_bestWeapon;

            if (_best isNotEqualTo "") then {
                _plan pushBack ["launcher", _best];
            };
        };
    };
};

// --- backpack ---
// Gap-fill only. Capacity is the one thing a backpack can be compared on, so the
// biggest on offer wins; swapping an occupied one would spill its contents for a few
// liters and is not worth the step
if (backpack _unit isEqualTo "" && {_bags isNotEqualTo []}) then {
    private _best = "";
    private _bestLoad = -1;

    {
        private _load = getNumber (configFile >> "CfgVehicles" >> _x >> "maximumLoad");

        if (_load > _bestLoad) then {
            _best = _x;
            _bestLoad = _load;
        };
    } forEach _bags;

    if (_best isNotEqualTo "") then {
        _plan pushBack ["backpack", _best];
    };
};

// --- worn armor, corpses only ---
// Crates hold vests and helmets as ITEM cargo, and the engine has no action for
// pulling one out and wearing it; a body wears them, which is what makes the swap
// expressible at all
if (_isBody) then {
    private _fnc_armor = {
        params ["_class", "_hitpoint"];

        if (_class isEqualTo "") exitWith {-1};

        getNumber (configFile >> "CfgWeapons" >> _class >> "ItemInfo" >> "HitpointsProtectionInfo" >> _hitpoint >> "armor")
    };

    private _vest = vest _target;

    if (
        _vest isNotEqualTo ""
        && {vest _unit isEqualTo "" || {_upgrade}}
        && {([_vest, "Chest"] call _fnc_armor) > ([vest _unit, "Chest"] call _fnc_armor)}
    ) then {
        _plan pushBack ["vest", _vest];
    };

    private _headgear = headgear _target;

    if (
        _headgear isNotEqualTo ""
        && {headgear _unit isEqualTo "" || {_upgrade}}
        && {([_headgear, "Head"] call _fnc_armor) > ([headgear _unit, "Head"] call _fnc_armor)}
    ) then {
        _plan pushBack ["headgear", _headgear];
    };
};

// --- specialist items ---
if (GVAR(takeItems) && {_items isNotEqualTo []}) then {
    // What the unit is short of, by kind. Night vision is read off the head-mounted
    // slot rather than the item list, because that is where an equipped set lives
    private _wanted = [];

    if (hmd _unit isEqualTo "") then {_wanted pushBack "nvgoggles"};

    private _held = [];

    {
        _held pushBackUnique (([_x] call FUNC(itemCategory)) select 1);
    } forEach (items _unit);

    {
        _x params ["_kind", "_allowed"];

        if (_allowed && {!(_kind in _held)}) then {_wanted pushBack _kind};
    } forEach [
        ["firstaidkit", true],
        ["medikit", _medic],
        ["toolkit", _engineer],
        ["minedetector", _eod]
    ];

    if (_wanted isNotEqualTo []) then {
        {
            private _kind = ([_x] call FUNC(itemCategory)) select 1;

            // Struck off as it is claimed, so a crate full of first aid kits yields
            // one step and not thirty. Night vision is its own step kind because it
            // has to be LINKED to the head slot to be of any use - dropped into the
            // inventory by the generic take action it would just be carried around
            if (_kind in _wanted) then {
                _plan pushBack [["item", "nvg"] select (_kind isEqualTo "nvgoggles"), _x];
                _wanted deleteAt (_wanted find _kind);
            };
        } forEach _items;
    };
};

// --- ammunition ---
// Always last. The engine tops up the magazines for the weapons the unit is HOLDING,
// so running it before the take steps - which is what this component used to do, all
// three actions fired into the same frame - refilled the weapon he was about to throw
// away and left the new one empty
if (_plan isNotEqualTo [] || {[_unit, _offered] call FUNC(offersAmmo)}) then {
    _plan pushBack ["rearm", ""];
};

_plan
