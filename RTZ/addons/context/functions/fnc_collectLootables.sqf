#include "script_component.hpp"
/*
 * rtz_fnc_collectLootables
 *
 * Finds lootable objects around a position: dead bodies carrying gear, weapon
 * holders (dropped weapons), supply crates, and unmanned vehicles with cargo.
 * Candidates come from a single nearestObjects call (nearest-first) and each
 * one is filtered with cheap early-exit checks, so the function is safe to run
 * from the context-menu condition on every menu open. Pass a _limit of 1 for
 * the condition path — it stops scanning at the first hit.
 *
 * Cargo state and corpses are synced globally, so this works identically on a
 * client (menu condition) and on the server (FUNC(lootNearbyApply)).
 *
 * Not lootable: living men, manned or destroyed vehicles, bodies inside
 * vehicles (AI can't path to them), curator-hidden objects, and anything with
 * completely empty cargo.
 *
 * Parameters:
 *   0: Position — center of the search
 *   1: Number   — search radius in meters (default 50)
 *   2: Number   — stop after this many hits; 0 = no limit (default 0)
 *
 * Returns: Array of lootable objects, nearest-first
 */

params [["_pos", [0, 0, 0]], ["_radius", 50], ["_limit", 0]];

private _out = [];
scopeName "scan";
{
    private _obj = _x;
    private _lootable = !isObjectHidden _obj && {
        if (_obj isKindOf "CAManBase") then {
            // A corpse on foot, carrying at least something worth walking to.
            !alive _obj && {isNull objectParent _obj} && {
                weapons _obj isNotEqualTo []
                || {backpack _obj isNotEqualTo ""}
                || {vest _obj isNotEqualTo ""}
            }
        } else {
            // Crate / weapon holder / vehicle: intact, unmanned, non-empty cargo.
            // A wreck's inventory is inaccessible; a manned vehicle is someone's ride.
            alive _obj
            && {(crew _obj) findIf { alive _x } == -1}
            && {
                ((getWeaponCargo _obj) select 0) isNotEqualTo []
                || {((getMagazineCargo _obj) select 0) isNotEqualTo []}
                || {((getItemCargo _obj) select 0) isNotEqualTo []}
                || {((getBackpackCargo _obj) select 0) isNotEqualTo []}
            }
        }
    };
    if (_lootable) then { _out pushBack _obj };

    // exitWith only continues to the next forEach iteration, not a real break —
    // scopeName/breakOut is what actually terminates the loop early.
    if (_limit > 0 && {count _out >= _limit}) then { breakOut "scan"; };
} forEach nearestObjects [_pos, ["ThingX", "WeaponHolder", "WeaponHolderSimulated", "AllVehicles"], _radius];

_out
