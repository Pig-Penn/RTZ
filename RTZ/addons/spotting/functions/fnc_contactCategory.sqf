#include "script_component.hpp"
/*
 * Author: Maxim
 * Human-readable contact category for radio reports — "infantry", "armor", etc.
 * Classified from the vehicle the unit occupies (the unit itself when on foot).
 * Returns a mass/plural noun so it reads cleanly as "Enemy <x> spotted".
 *
 * Arguments:
 * 0: Unit to categorize (typically the group leader). May be a vehicle rather than a
 *    man — FUNC(spotCheck) anchors on a hull when the group's leader is not
 *    spottable — in which case that vehicle is categorized <OBJECT>
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

// Vehicle to categorize by, or objNull for on foot. objectParent for a man (already
// objNull on foot, no `== _unit` sentinel needed); the object itself when it IS a
// vehicle, since a hull's own objectParent is objNull and would read as "on foot".
private _veh = if (_unit isKindOf "CAManBase") then { objectParent _unit } else { _unit };

// Most-specific class first: Tank inherits from LandVehicle, so testing
// LandVehicle first would swallow every tank/IFV into "vehicles" and make the
// armor branch unreachable. Air and Ship are disjoint from LandVehicle and from
// each other (submarines are Ship-kind — there is no separate Submarine base
// class), so their order is free.
if (isNull _veh)                  exitWith { LLSTRING(CategoryInfantry) };
if (_veh isKindOf "Tank")         exitWith { LLSTRING(CategoryArmor) };
if (_veh isKindOf "LandVehicle")  exitWith { LLSTRING(CategoryVehicles) };
if (_veh isKindOf "Air")          exitWith { LLSTRING(CategoryAircraft) };
if (_veh isKindOf "Ship")         exitWith { LLSTRING(CategoryNaval) };

LLSTRING(CategoryInfantry)
