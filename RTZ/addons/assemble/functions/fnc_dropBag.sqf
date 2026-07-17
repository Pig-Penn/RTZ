#include "script_component.hpp"
/*
 * Author: Maxim
 * Spawn a backpack on the ground at a position. The "no taker" fallback the
 * pack paths repeat whenever a bag can't be handed to a carrier (a dead gunner, an
 * assistant already wearing a bag, an unknown drone operator).
 *
 * Arguments:
 * 0: Backpack Class <STRING> - "" spawns nothing
 * 1: Position ATL <ARRAY>
 *
 * Return Value:
 * Spawned Bag <OBJECT> - objNull when the class was ""
 *
 * Example:
 * ["B_HMG_01_support_F", getPosATL _weapon] call rtz_assemble_fnc_dropBag
 *
 * Public: No
 */

params [["_bagClass", "", [""]], "_position"];

if (_bagClass isEqualTo "") exitWith {objNull};

private _bag = createVehicle [_bagClass, [0, 0, 0], [], 0, "CAN_COLLIDE"];
_bag setPosATL _position;

_bag
