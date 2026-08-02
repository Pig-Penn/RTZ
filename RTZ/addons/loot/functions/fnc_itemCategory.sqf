#include "script_component.hpp"
/*
 * Author: Maxim
 * Classifies one inventory classname into [category, kind] - the taxonomy the whole
 * loot planner is built on. Memoized: a class is resolved from config exactly once
 * per session and answered from GVAR(categories) forever after.
 *
 * The work is delegated to BIS_fnc_itemType rather than reimplemented, for two
 * reasons. It classifies by the weapon's CURSOR, not by its class hierarchy, so a
 * modded rifle that inherits from something unexpected still lands on "assaultrifle"
 * as long as it draws a rifle crosshair - and it already handles CfgWeapons >> type
 * being declared as a STRING, which a bare getNumber reads as 0.
 *
 * That function walks config on every call, which is far too slow for something the
 * planner hits once per weapon per lootable per unit. Hence the cache: it is the same
 * bargain rtz_assemble strikes with GVAR(bagInfo), except filled lazily instead of by
 * an up-front sweep. A modset carries tens of thousands of CfgWeapons classes and a
 * mission touches a few hundred of them, so scanning them all at preInit would pay
 * for a table that is almost entirely never read.
 *
 * Both halves come back lowercase, so callers compare against literals without
 * case-folding at every site.
 *
 * Arguments:
 * 0: Class <STRING>
 *
 * Return Value:
 * 0: Category <STRING> - "weapon", "item", "equipment", "magazine", ""
 * 1: Kind <STRING> - "assaultrifle", "sniperrifle", "missilelauncher", "firstaidkit", ...
 *
 * Example:
 * ([primaryWeapon _unit] call rtz_loot_fnc_itemCategory) params ["_category", "_kind"];
 *
 * Public: No
 */

params ["_class"];

if (_class isEqualTo "") exitWith {["", ""]};

private _key = toLowerANSI _class;
private _cached = GVAR(categories) get _key;

if (!isNil "_cached") exitWith {_cached};

([_class] call BIS_fnc_itemType) params [["_category", ""], ["_kind", ""]];

private _entry = [toLowerANSI _category, toLowerANSI _kind];
GVAR(categories) set [_key, _entry];

_entry
