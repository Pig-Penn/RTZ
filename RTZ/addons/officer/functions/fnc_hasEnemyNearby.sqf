#include "script_component.hpp"
/*
 * Author: Maxim
 * Checks whether any live enemy is within the officer's editing-area radius
 * (GVAR(areaRadius)) of his current position. Used to forbid placing a new
 * area on top of a position the enemy is already contesting.
 *
 * Arguments:
 * 0: Officer <OBJECT>
 *
 * Return Value:
 * Enemy Nearby <BOOLEAN>
 *
 * Example:
 * [_officer] call rtz_officer_fnc_hasEnemyNearby
 *
 * Public: No
 */

params ["_officer"];

private _side = side _officer;
private _pos = getPosWorld _officer;

//(_pos nearEntities [["CAManBase", "LandVehicle", "Air", "Ship"], GVAR(areaRadius)]) findIf {
//    alive _x && {side _x getFriend _side < HOSTILE_THRESHOLD}
//} != -1
