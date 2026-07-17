#include "script_component.hpp"
/*
 * Author: Maxim
 * Lightweight assemble path for a UAV operator's bag. Unlike a manned static
 * weapon a drone isn't walked into place and cranked up by hand, the operator
 * deploys it on the spot, so this stays instant and animation free: consume the bag,
 * spawn the drone in front of the operator, give it an AI crew on his side and link
 * his terminal so he keeps flying it on foot (matching a vanilla assemble), tag him
 * so a later disassemble returns the bag to him, and grant Zeus ownership of the
 * drone and its crew.
 *
 * Split out of the manned assemble flow (FUNC(assembleWeapon) routes here for any
 * assembleTo that is not a StaticWeapon) so neither path carries the other's special
 * casing. Mirror of FUNC(disassembleUAV).
 *
 * Arguments:
 * 0: UAV Operator <OBJECT> - carries the drone bag
 * 1: Drone Class <STRING> - assembleInfo >> assembleTo
 *
 * Return Value:
 * None
 *
 * Example:
 * [_operator, "B_UAV_01_F"] call rtz_assemble_fnc_assembleUAV
 *
 * Public: No
 */

params ["_gunner", "_staticClass"];

if (isNull _gunner) exitWith {};

private _direction = getDir _gunner;
private _position = getPosATL _gunner;

removeBackpackGlobal _gunner;

// Build a step in front of the operator so it doesn't spawn on top of him
private _drone = createVehicle [_staticClass, [0, 0, 0], [], 0, "CAN_COLLIDE"];
_drone setDir _direction;
_drone setPosATL (_position vectorAdd [sin _direction, cos _direction, 0]);
_drone setVectorUp (surfaceNormal (getPos _drone));

// moveInGunner would fail on a seat a drone doesn't have, leaving an empty
// uncontrolled UAV. Give it an AI crew on the operator's side and link his terminal
// instead, the way a vanilla assemble does
(side _gunner) createVehicleCrew _drone;
_gunner connectTerminalToUAV _drone;

// On disassemble the drone's "gunner" is its throwaway AI crew, so the weapon bag
// must return to this operator (read by FUNC(disassembleUAV))
SETPVAR(_drone,GVAR(operator),_gunner);

// addCrew = true also registers the drone's AI crew with the curator
[_drone, _gunner, true] call FUNC(grantCurators);
