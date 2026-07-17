#include "script_component.hpp"
/*
 * Author: Maxim
 * Resolves a Zeus selection to the manned static weapons, or assembled drones, that
 * can be packed back into backpacks. Reverse of FUNC(collectAssembleSets): a
 * selected weapon contributes itself, a selected crewman contributes his vehicle.
 *
 * Membership in FUNC(getDisassembleMap) is the only class filter (a class is in the
 * map exactly when it assembles from a bag) - class tree checks like
 * isKindOf "UAV" would miss the quadcopter family, which inherits from
 * Helicopter_Base_H rather than the legacy UAV class. A gunner is required because
 * he performs the pack and receives the weapon bag (a drone's is its AI crew, the
 * lightweight UAV path returns the bag to the tagged operator instead).
 *
 * Arguments:
 * 0: Selected Objects <ARRAY>
 *
 * Return Value:
 * Disassemble Sets <ARRAY of ARRAY> - one [weapon <OBJECT>, gunner <OBJECT>, weapon
 * bag <STRING>, support bags <ARRAY of STRING>] per weapon. [] when nothing
 * selected can be disassembled.
 *
 * Example:
 * [_objects] call rtz_assemble_fnc_collectDisassembleSets
 *
 * Public: No
 */

params ["_objects"];

private _map = call FUNC(getDisassembleMap);

// Unique candidate weapons: vehicle _x resolves a crewman to his mount and a
// vehicle to itself (a man on foot resolves to himself, never in the map)
private _weapons = [];
{
    if (_x isEqualType objNull && {!isNull _x}) then {
        private _vehicle = vehicle _x;

        if ((toLower typeOf _vehicle) in _map) then {
            _weapons pushBackUnique _vehicle;
        };
    };
} forEach _objects;

private _sets = [];
{
    private _gunner = gunner _x;

    if (alive _x && {!isNull _gunner}) then {
        (_map get (toLower typeOf _x)) params ["_weaponBag", "_baseBags"];
        _sets pushBack [_x, _gunner, _weaponBag, _baseBags];
    };
} forEach _weapons;

_sets
