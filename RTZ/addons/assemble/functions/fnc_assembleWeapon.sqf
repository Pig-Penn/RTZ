#include "script_component.hpp"
/*
 * Author: Maxim
 * Handler body for QGVAR(assemble) (the receiver is registered in
 * XEH_postInit). Routes one carried assemble set to its build path:
 *   - a UAV operator's bag deploys instantly into an autonomous drone on the spot
 *     (FUNC(assembleUAV) - lightweight, no walk, no animation)
 *   - a manned static weapon is walked to the picked cursor spot by its gunner and
 *     assistant, then raised with the real engine assemble animation (arrival, or a
 *     walk timeout, hands off to FUNC(buildWeapon))
 *
 * doMove, createVehicle and the assemble action all need the gunner local, so the
 * whole errand lives here and FUNC(orderAssemble) dispatches each set to his owner
 * with CBA_fnc_targetEvent - the server for ordinary Zeus AI, a headless client or a
 * player's machine for offloaded or player-led groups. Must be executed where the
 * gunner is local. The Zeus grant at the end of the build hops back to the server on
 * its own, see FUNC(grantCurators).
 *
 * Arguments:
 * 0: Gunner <OBJECT> - carries the primary weapon bag
 * 1: Static Class <STRING> - assembleInfo >> assembleTo
 * 2: Assistant <OBJECT> - carries the support bag, objNull for single bag and UAVs
 * 3: Position ATL <ARRAY> - the cursor spot to build at (default: the gunner's own)
 * 4: Direction <NUMBER> - facing chosen in the placement preview, -1 auto-faces the
 *    nearest known enemy (default: -1)
 * 5: Curator's Player <OBJECT> - feedback toasts (default: objNull)
 *
 * Return Value:
 * None
 *
 * Example:
 * [_gunner, "B_HMG_01_F", _assistant, _position, 180, player] call rtz_assemble_fnc_assembleWeapon
 *
 * Public: No
 */

params ["_gunner", "_staticClass", "_assistant", ["_position", []], ["_direction", -1], ["_curator", objNull]];

if (isNull _gunner || {!alive _gunner}) exitWith {};
if (!isClass (configFile >> "CfgVehicles" >> _staticClass)) exitWith {};

if (!local _gunner) exitWith {
    [_curator, LLSTRING(GunnerNotLocal)] call FUNC(notifyCurator);
};

// A UAV operator's bag becomes an autonomous drone deployed on the spot - no tripod
// to walk in, no gunner seat. Lightweight, instant, separate path
if (!(_staticClass isKindOf "StaticWeapon")) exitWith {
    [_gunner, _staticClass] call FUNC(assembleUAV);
};

// Guard against a double right-click queueing two builds for the same gunner
if (_gunner getVariable [QGVAR(assembling), false]) exitWith {};
_gunner setVariable [QGVAR(assembling), true];

if (_position isEqualTo []) then {
    _position = getPosATL _gunner;
};

// Instant assembly: skip the walk, put the gunner at the picked spot and build now.
// FUNC(buildWeapon) likewise skips the engine animation, so the weapon appears at
// the cursor at once
if (GVAR(instant)) exitWith {
    _gunner setPosATL _position;
    [_gunner, _staticClass, _assistant, _direction, _curator] call FUNC(buildWeapon);
};

private _crew = [_gunner];

if (!isNull _assistant && {alive _assistant}) then {
    _crew pushBack _assistant;
};

// Walk the crew to the spot, then raise the weapon. Build on arrival, or in place on
// the gunner's death or the timeout, so a Zeus order always completes
[
    _crew,
    _position,
    ARRIVE_DISTANCE,
    WALK_TIMEOUT_BASE + (_gunner distance2D _position) * WALK_TIMEOUT_PER_METER,
    LINKFUNC(buildWeapon),
    LINKFUNC(buildWeapon),
    [_gunner, _staticClass, _assistant, _direction, _curator],
    true,
    _curator,
    LLSTRING(BuildInPlace)
] call EFUNC(common,approach);
