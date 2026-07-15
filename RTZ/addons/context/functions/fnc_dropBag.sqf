#include "script_component.hpp"
/*
 * rtz_fnc_dropBag
 *
 * SERVER: spawn a backpack on the ground at a position — the "no taker" fallback
 * the disassemble paths repeat whenever a bag can't be handed to a carrier (dead
 * gunner, assistant already wearing a bag, unknown drone operator).
 *
 * Parameters:
 *   0: String — backpack class ("" → nothing spawned)
 *   1: Array  — world position (ATL) to drop at
 * Returns: Object — the spawned bag (objNull when class was "")
 */

params [["_bagClass", ""], "_pos"];
if (_bagClass isEqualTo "") exitWith { objNull };

private _bag = createVehicle [_bagClass, [0, 0, 0], [], 0, "CAN_COLLIDE"];
_bag setPosATL _pos;
_bag
