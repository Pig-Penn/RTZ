#include "script_component.hpp"
/*
 * rtz_fnc_findMineMag
 *
 * Returns the classname of the first placeable mine magazine a unit is carrying,
 * or "" if it carries none. A magazine counts as a mine when its ammo config
 * inherits from CfgAmmo >> MineBase (AP/AT proximity & pressure mines — the
 * ammo classes createMine expects). Remote-detonated charges (satchel/demo,
 * PipeBomb) are intentionally excluded: they are not proximity mines and
 * createMine does not build them into working devices.
 *
 * magazines reads across all of the unit's containers (uniform/vest/backpack)
 * and is readable on remote units, so this works from the client (context-menu
 * condition) and the server (placement) alike.
 *
 * Parameters:
 *   0: Object — unit to inspect
 * Returns: String — mine magazine classname, or "" when none is carried
 */

params ["_unit"];

private _res = "";
scopeName "search";
{
    private _ammo = getText (configFile >> "CfgMagazines" >> _x >> "ammo");
    if (_ammo isNotEqualTo "" && {_ammo isKindOf ["MineBase", configFile >> "CfgAmmo"]}) then {
        _res = _x;
        breakOut "search";
    };
} forEach magazines _unit;

_res
