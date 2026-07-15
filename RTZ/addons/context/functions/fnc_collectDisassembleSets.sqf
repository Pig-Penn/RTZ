#include "script_component.hpp"
/*
 * rtz_fnc_collectDisassembleSets
 *
 * Resolves a Zeus selection to the list of manned static weapons — or assembled
 * drones — that can be packed back into backpacks. Reverse of FUNC(collectAssembleSets):
 * a selected static weapon (or drone) contributes itself; a selected crewman
 * contributes his vehicle. Membership in the disassemble map is the only class
 * filter (a class is in the map exactly when it assembles from a bag) — class-tree
 * checks like isKindOf "UAV" would miss the quadcopter family, which inherits
 * from Helicopter_Base_H, not the legacy UAV class. A gunner is required because
 * he performs the pack and receives the weapon bag (a drone's is its AI crew; the
 * lightweight UAV path returns the bag to the tagged operator instead).
 *
 * Parameters:
 *   0: Array — objects from curatorSelected / a ZEN action's selection + hovered
 * Returns: Array of [_weapon, _gunner, _weaponBag, _baseBags] sets; [] when
 *          nothing selected can be disassembled.
 */

params ["_objects"];
private _map = call FUNC(buildDisassembleMap);

// Collect unique candidate weapons: vehicle _x resolves a crewman to his mount
// and a vehicle to itself (a man on foot resolves to himself — never in the map).
private _statics = [];
{
    if (_x isEqualType objNull && {!isNull _x}) then {
        private _veh = vehicle _x;
        if ((toLower typeOf _veh) in _map) then { _statics pushBackUnique _veh; };
    };
} forEach _objects;

private _sets = [];
{
    private _gunner = gunner _x;
    if (alive _x && {!isNull _gunner}) then {
        (_map get (toLower typeOf _x)) params ["_weaponBag", "_baseBags"];
        _sets pushBack [_x, _gunner, _weaponBag, _baseBags];
    };
} forEach _statics;

_sets
