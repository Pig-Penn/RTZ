#include "script_component.hpp"
/*
 * Author: Maxim
 * Human-readable contact category for radio reports — "infantry", "armor", etc.
 * Classified from the vehicle the unit occupies (the unit itself when on foot).
 * Returns a mass/plural noun so it reads cleanly as "Enemy <x> spotted".
 *
 * Arguments:
 * 0: Unit to categorize (typically the group leader) <OBJECT>
 *
 * Return Value:
 * Contact category <STRING>
 *
 * Example:
 * [_leader] call rtz_spotting_fnc_contactCategory
 *
 * Public: No
 */

params ["_unit"];

private _veh = vehicle _unit;
if (_veh isKindOf "Air")                                      exitWith { LLSTRING(CategoryAircraft) };
if (_veh isKindOf "Ship" || { _veh isKindOf "Submarine" })    exitWith { LLSTRING(CategoryNaval) };
if (_veh isKindOf "Tank")                                     exitWith { LLSTRING(CategoryArmor) };
if (_veh isKindOf "LandVehicle" && { _veh != _unit })         exitWith { LLSTRING(CategoryVehicles) };
LLSTRING(CategoryInfantry)
