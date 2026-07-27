#include "script_component.hpp"
/*
 * Author: Maxim
 * Finds lootable objects around a position: dead bodies carrying gear, weapon
 * holders (dropped weapons), supply crates, and unmanned vehicles with cargo.
 * Candidates come from a single nearestObjects call (nearest-first) and each one is
 * filtered with cheap early-exit checks, so this is safe to run from the context menu
 * condition on every menu open. Pass a limit of 1 for the condition path - it stops
 * scanning at the first hit.
 *
 * Cargo state and corpses are synced globally, so this returns the same list on a
 * client (the menu condition, FUNC(canLoot)) and on the server (FUNC(lootSquads)).
 *
 * Not lootable: living men, manned or destroyed vehicles, bodies inside vehicles
 * (AI can't path to them), curator-hidden objects, and anything with empty cargo.
 *
 * Arguments:
 * 0: Position <ARRAY> - center of the search
 * 1: Radius <NUMBER> - search radius in meters (default: 50)
 * 2: Limit <NUMBER> - stop after this many hits, 0 for no limit (default: 0)
 *
 * Return Value:
 * Lootable objects, nearest-first <ARRAY of OBJECT>
 *
 * Example:
 * [getPosATL leader _group, 50, 1] call rtz_loot_fnc_collectLootables
 *
 * Public: No
 */

params [["_position", [0, 0, 0]], ["_radius", 50], ["_limit", 0]];

private _lootables = [];

scopeName "scan";

{
    private _object = _x;

    private _isLootable = !isObjectHidden _object && {
        if (_object isKindOf "CAManBase") then {
            // A corpse on foot, carrying at least something worth walking to
            !alive _object && {isNull objectParent _object} && {
                weapons _object isNotEqualTo []
                || {backpack _object isNotEqualTo ""}
                || {vest _object isNotEqualTo ""}
            }
        } else {
            // Crate / weapon holder / vehicle: intact, unmanned, non-empty cargo.
            // A wreck's inventory is inaccessible, a manned vehicle is someone's ride
            alive _object
            && {(crew _object) findIf {alive _x} == -1}
            && {
                ((getWeaponCargo _object) select 0) isNotEqualTo []
                || {((getMagazineCargo _object) select 0) isNotEqualTo []}
                || {((getItemCargo _object) select 0) isNotEqualTo []}
                || {((getBackpackCargo _object) select 0) isNotEqualTo []}
            }
        }
    };

    if (_isLootable) then {
        _lootables pushBack _object;
    };

    // exitWith would only skip to the next forEach iteration rather than break -
    // scopeName/breakOut is what actually terminates the loop early. The value
    // MUST ride along: a bare `breakOut "scan"` exits the function scope with no
    // return value, so every limited scan (FUNC(canLoot) passes 1) handed its
    // caller nil the moment it found something - i.e. the Loot action's condition
    // broke precisely when there WAS loot to take
    if (_limit > 0 && {count _lootables >= _limit}) then {
        _lootables breakOut "scan";
    };
} forEach nearestObjects [_position, ["ThingX", "WeaponHolder", "WeaponHolderSimulated", "AllVehicles"], _radius];

_lootables
