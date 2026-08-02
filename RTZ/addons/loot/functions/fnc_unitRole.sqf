#include "script_component.hpp"
/*
 * Author: Maxim
 * What this unit is FOR: the weapon categories his role sanctions, whether that role
 * carries a launcher at all, and which specialist items he should be picking up.
 * This is what keeps a loot sweep from quietly rewriting a squad's composition -
 * without it, the first sniper rifle on the ground turns whichever rifleman happened
 * to be nearest into a marksman with no spotter and no role.
 *
 * Read from the unit's CONFIG loadout, not his live one, and memoized per typeOf in
 * GVAR(roles). Config is the right source because role has to survive the loadout:
 * a rifleman who has been disarmed is still a rifleman and must not come back from a
 * corpse field as an AT gunner, and a machine gunner who lost his MG must be able to
 * pick another one up. A live-loadout reading gets both of those backwards. Keying
 * the cache on typeOf rather than on the unit is what makes it worth having - a
 * forty-man sweep is a handful of distinct classes.
 *
 * The specialist flags come from the same config fields the engine itself uses to
 * decide who can revive and who can repair, so a modded medic that the engine treats
 * as a medic is treated as one here too.
 *
 * Arguments:
 * 0: Unit <OBJECT>
 *
 * Return Value:
 * 0: Primary Kinds <ARRAY of STRING> - weapon kinds this role is issued, may be empty
 * 1: Carries Launcher <BOOL> - whether the role is issued a launcher at all
 * 2: Medic <BOOL>
 * 3: Engineer <BOOL>
 * 4: EOD <BOOL>
 *
 * Example:
 * ([_unit] call rtz_loot_fnc_unitRole) params ["_kinds", "_launcher", "_medic"];
 *
 * Public: No
 */

params ["_unit"];

private _type = typeOf _unit;
private _cached = GVAR(roles) get _type;

if (!isNil "_cached") exitWith {_cached};

private _config = configFile >> "CfgVehicles" >> _type;

private _kinds = [];
private _launcher = false;

{
    ([_x] call FUNC(weaponScore)) params ["_slot", "_kind"];

    switch (_slot) do {
        case SLOT_PRIMARY: {_kinds pushBackUnique _kind};
        case SLOT_LAUNCHER: {_launcher = true};
    };
} forEach (getArray (_config >> "weapons"));

private _entry = [
    _kinds,
    _launcher,
    getNumber (_config >> "attendant") == 1,
    getNumber (_config >> "engineer") == 1,
    getNumber (_config >> "canDeactivateMines") == 1
];

GVAR(roles) set [_type, _entry];

_entry
