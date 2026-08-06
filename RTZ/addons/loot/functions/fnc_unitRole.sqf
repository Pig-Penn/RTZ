#include "script_component.hpp"
/*
 * Author: Maxim
 * Which specialist items this unit has any use for. Memoized per typeOf in GVAR(roles).
 *
 * The flags come from the same config fields the ENGINE itself uses to decide who can
 * revive, who can repair and who can defuse, so a modded medic the engine treats as a
 * medic is treated as one here too - and, more to the point, so the planner never sends
 * a rifleman to fetch a medikit he is not permitted to use. These three items are the
 * only genuine capability gates left in the component: everything else a unit can pick
 * up, he can also fire, wear or carry.
 *
 * This used to also report which weapon categories the role was ISSUED, and whether it
 * carried a launcher at all, and FUNC(lootPlan) used both as a veto. It no longer does -
 * a rifleman standing over a machine gun or a live AT tube takes it. What remains of the
 * old design is the choice to read CONFIG rather than the live loadout, which is still
 * right for what is left: a medic who has been stripped of his medikit is still a medic
 * and must be able to pick another one up.
 *
 * Keying the cache on typeOf rather than on the unit is what makes it worth having - a
 * forty-man sweep is a handful of distinct classes.
 *
 * Arguments:
 * 0: Unit <OBJECT>
 *
 * Return Value:
 * 0: Medic <BOOL>
 * 1: Engineer <BOOL>
 * 2: EOD <BOOL>
 *
 * Example:
 * ([_unit] call rtz_loot_fnc_unitRole) params ["_medic", "_engineer", "_eod"];
 *
 * Public: No
 */

params ["_unit"];

private _type = typeOf _unit;
private _cached = GVAR(roles) get _type;

if (!isNil "_cached") exitWith {_cached};

private _config = configFile >> "CfgVehicles" >> _type;

private _entry = [
    getNumber (_config >> "attendant") == 1,
    getNumber (_config >> "engineer") == 1,
    getNumber (_config >> "canDeactivateMines") == 1
];

GVAR(roles) set [_type, _entry];

_entry
