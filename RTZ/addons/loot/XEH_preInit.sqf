#include "script_component.hpp"

ADDON = false;

PREP_RECOMPILE_START;
#include "XEH_PREP.hpp"
PREP_RECOMPILE_END;

// How good a weapon of each kind is FOR ITS SLOT, keyed by the kind FUNC(itemCategory)
// resolves a class to. Machine guns and sniper rifles outrank the rifles, SMGs and
// shotguns; a guided missile launcher outranks an unguided rocket launcher. The slot
// comes from the same table, so nothing downstream has to read CfgWeapons >> type -
// a field a handful of mods declare as a STRING, where getNumber quietly returns 0
// and the weapon falls out of every slot test.
//
// A kind absent from this table fills no slot and is never looted: handguns,
// binoculars, vehicle armament, and anything modded whose cursor resolves to none of
// the above. BIS_fnc_itemType falls back to "rifle" for an unrecognized primary and
// "launcher" for an unrecognized launcher, so modded weapons still land on a real
// entry rather than dropping out.
GVAR(ranks) = createHashMapFromArray [
    ["assaultrifle",    [SLOT_PRIMARY, 1]],
    ["rifle",           [SLOT_PRIMARY, 1]],
    ["submachinegun",   [SLOT_PRIMARY, 1]],
    ["shotgun",         [SLOT_PRIMARY, 1]],
    ["machinegun",      [SLOT_PRIMARY, 2]],
    ["sniperrifle",     [SLOT_PRIMARY, 2]],
    ["launcher",        [SLOT_LAUNCHER, 1]],
    ["rocketlauncher",  [SLOT_LAUNCHER, 1]],
    ["missilelauncher", [SLOT_LAUNCHER, 2]]
];

// Filled lazily rather than by an up-front config sweep: a modset carries tens of
// thousands of CfgWeapons classes and a mission touches a few hundred of them, so
// scanning them all here would pay for a table that is almost entirely never read.
// See FUNC(itemCategory) for the bargain in full.
GVAR(categories) = createHashMap;
GVAR(scores) = createHashMap;
GVAR(roles) = createHashMap;

// Memo behind FUNC(collectLootables). Seeded on every machine: the curator's client
// fills it from the context menu condition and the server from the order itself, and
// each is memoizing its own repeats.
GVAR(scanCache) = createHashMap;

#include "initSettings.inc.sqf"

ADDON = true;
