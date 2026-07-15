#include "script_component.hpp"
/*
 * rtz_fnc_grantCurators
 *
 * SERVER: grant a server-spawned object to the curators who own a reference unit.
 * A createVehicle on the server enters no curator's editable set, so Zeus would
 * lose control of the new object; this hands it to every curator who can already
 * edit the reference unit (keeping per-officer ownership), or to all live curators
 * if none can, so it is never orphaned. Curator modules are server-local, so the
 * direct addCuratorEditableObjects call is valid here.
 *
 * Extracted from the assemble flow so the manned-static build (FUNC(assembleWeaponFinalize))
 * and the drone deploy (FUNC(assembleUAV)) share one implementation.
 *
 * Parameters:
 *   0: Object  — the newly-spawned object to grant
 *   1: Object  — reference unit whose owning curators inherit it
 *   2: Boolean — addCrew: also register the object's crew (default false; true for UAVs)
 */

params ["_obj", "_ref", ["_addCrew", false]];
if (isNull _obj) exitWith {};

private _owners = allCurators select { !isNull _x && {_ref in curatorEditableObjects _x} };
if (_owners isEqualTo []) then { _owners = allCurators select { !isNull _x }; };
{ _x addCuratorEditableObjects [[_obj], _addCrew] } forEach _owners;
