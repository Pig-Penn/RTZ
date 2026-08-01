#include "script_component.hpp"
/*
 * Author: Maxim
 * Grants a freshly spawned object to the curators who own a reference unit. A
 * scripted createVehicle enters no curator's editable set, so Zeus would lose
 * control of the new object. This hands it to every curator who can already edit
 * the reference unit (keeping per-officer ownership), or to all live curators if
 * none can, so it is never orphaned.
 *
 * The grant itself only ever runs on the SERVER: curator modules are server-local
 * and addCuratorEditableObjects needs its curator argument local. The errands that
 * call this run wherever their unit is local, which for AI offloaded to a headless
 * client or in a player-led group is not the server, so a non-server caller
 * forwards the grant over QGVAR(grantCurators) (the receiver is registered in
 * XEH_postInit).
 *
 * Arguments:
 * 0: Newly Spawned Object <OBJECT>
 * 1: Reference Unit <OBJECT> - its owning curators inherit the object
 * 2: Add Crew <BOOL> - also register the object's crew, true for UAVs (default: false)
 *
 * Return Value:
 * None
 *
 * Example:
 * [_weapon, _gunner] call rtz_common_fnc_grantCurators
 *
 * Public: No
 */

params ["_object", "_reference", ["_addCrew", false]];

if (isNull _object) exitWith {};

// Ran somewhere other than the server — hand the grant over to it. createVehicle and
// createVehicleCrew both have global effect, so the object exists server-side by the
// time this arrives; the isNull guard above catches it there if it somehow doesn't
if (!isServer) exitWith {
    [QGVAR(grantCurators), [_object, _reference, _addCrew]] call CBA_fnc_serverEvent;
};

{
    _x addCuratorEditableObjects [[_object], _addCrew];
} forEach ([_reference, true] call FUNC(curatorsOf));
