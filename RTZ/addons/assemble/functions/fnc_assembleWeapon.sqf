#include "script_component.hpp"
/*
 * Author: Maxim
 * Handler body for QGVAR(assemble) (the receiver is registered in
 * XEH_postInit). Routes one carried assemble set to its build path:
 *   - a UAV operator's bag deploys instantly into an autonomous drone on the spot
 *     (FUNC(assembleUAV) - lightweight, no walk, no animation)
 *   - a manned static weapon is walked to the picked cursor spot by its gunner, with
 *     the assistant flanking it, then raised with the real engine assemble animation
 *     (arrival, or a walk timeout, hands off to FUNC(buildWeapon))
 *
 * doMove, createVehicle and the assemble action all need the gunner local, so the
 * whole errand lives here and FUNC(orderAssemble) dispatches each set to his owner
 * with CBA_fnc_targetEvent - the server for ordinary Zeus AI, a headless client or a
 * player's machine for offloaded or player-led groups. Must be executed where the
 * gunner is local. The Zeus grant at the end of the build hops back to the server on
 * its own, see EFUNC(common,grantCurators).
 *
 * Arguments:
 * 0: Gunner <OBJECT> - carries the primary weapon bag
 * 1: Static Class <STRING> - assembleInfo >> assembleTo
 * 2: Assistant <OBJECT> - carries the support bag, objNull for single bag and UAVs
 * 3: Position AGL <ARRAY> - the cursor spot to build at, as reported by
 *    EFUNC(common,placementPreview) (default: the gunner's own)
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
    [_curator, LLSTRING(GunnerNotLocal)] call EFUNC(common,notifyCurator);
};

// The bag is re-read here rather than trusted from the order: the gunner may have
// been stripped, killed and revived or already spent it between the right-click and
// this event. One config read per order - the cached GVAR(bagInfo) is built only on
// machines with an interface, and this runs wherever the gunner is local
if (getText (configFile >> "CfgVehicles" >> backpack _gunner >> "assembleInfo" >> "assembleTo") != _staticClass) exitWith {};

if (_position isEqualTo []) then {
    _position = ASLToAGL getPosASL _gunner;
};

private _walkTimeout = WALK_TIMEOUT_BASE + (_gunner distance2D _position) * WALK_TIMEOUT_PER_METER;

// Claim the gunner, so a double right-click can't queue two builds for him - and so
// the context menu (FUNC(findAssembleSets)) stops offering him. Two details matter:
//
// - The claim is public. The menu is filtered on the ordering curator's client while
//   this runs wherever the gunner is local, which on a dedicated server is another
//   machine entirely - a local variable would be invisible to the only reader.
// - It stores its own deadline rather than a flag, so it lapses on its own. An
//   unrelated errand ordered onto the same man mid-build (a mine to lay, bodies to
//   loot) supersedes this one inside EFUNC(common,approach), and a superseded order's
//   hooks never fire - a plain flag would then hide Assemble on that man for the rest
//   of the mission.
//
// Claimed before the UAV split so a fast double order can't deploy two drones off one
// bag; the drone path releases it again the moment it is done
if (CBA_missionTime < (_gunner getVariable [QGVAR(assembling), 0])) exitWith {};
SETPVAR(_gunner,GVAR(assembling),CBA_missionTime + _walkTimeout + SETTLE_TIMEOUT + BUILD_TIMEOUT);

// A UAV operator's bag becomes an autonomous drone deployed on the spot - no tripod
// to walk in, no gunner seat. Lightweight, instant, separate path
if (!(_staticClass isKindOf "StaticWeapon")) exitWith {
    [_gunner, _staticClass] call FUNC(assembleUAV);
    SETPVAR(_gunner,GVAR(assembling),nil);
};

// Instant assembly: skip the walk, put the gunner at the picked spot and build now.
// FUNC(buildWeapon) likewise skips the engine animation, so the weapon appears at
// the cursor at once. Placed through ASL so the gunner lands exactly where the
// preview ghost stood, including on a roof or a bridge
if (GVAR(instant)) exitWith {
    _gunner setPosASL (AGLToASL _position);
    [_gunner, _staticClass, _assistant, _direction, _curator] call FUNC(buildWeapon);
};

// The gunner walks to the picked spot itself - the weapon is raised where he stands,
// so sending him anywhere else would drift the static off the preview ghost. The
// assistant instead gets a stand-point of his own, CREW_SPREAD meters to the side:
// clear of the footprint the static is about to occupy, but inside the reach the
// engine's "PutBag" half needs. Vanilla's BIS_fnc_unpackStaticWeapon flanks the spot
// the same way
private _crew = [_gunner];

if (!isNull _assistant && {alive _assistant}) then {
    // Perpendicular to the facing the weapon will take. With no preview facing (-1,
    // auto-aim at the nearest enemy, which FUNC(finishBuild) only resolves once the
    // weapon exists) the crew's own approach bearing stands in - either way the
    // assistant ends up beside the gunner rather than in front of the muzzle
    private _facing = if (_direction >= 0) then {_direction} else {_position getDir _gunner};
    _crew pushBack [_assistant, _position getPos [CREW_SPREAD, _facing + 90]];
};

// Walk the crew to the spot, then raise the weapon. Build on arrival, or in place on
// the gunner's death or the timeout, so a Zeus order always completes
[
    _crew,
    _position,
    ARRIVE_DISTANCE,
    _walkTimeout,
    LINKFUNC(buildWeapon),
    LINKFUNC(buildWeapon),
    [_gunner, _staticClass, _assistant, _direction, _curator],
    true,
    _curator,
    LLSTRING(BuildInPlace)
] call EFUNC(common,approach);
