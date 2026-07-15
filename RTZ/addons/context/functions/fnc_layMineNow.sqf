#include "script_component.hpp"
/*
 * rtz_fnc_layMineNow
 *
 * SERVER: consumes one of the unit's mine magazines and builds the mine at its
 * feet. Called by FUNC(processMineQueue) once the unit has walked to a queued
 * spot and finished its plant animation. createMine takes the magazine's ammo
 * class (e.g. APERSMine_Range_Mag -> "APERSMine"); the mine is then revealed to
 * the layer's side so friendly AI paths around it and the friendly curator sees
 * it (the existing mine-display reads engine detection state).
 *
 * createMine / removeMagazineGlobal / revealMine are global-effect and must run
 * on the server, which is where this is called.
 *
 * Parameters:
 *   0: Object — mine-laying unit (already at the spot)
 */

// Defuse/detection difficulty of the placed mine (matches Antistasi's usage).
#define MINE_SKILL 50

params ["_unit"];

private _mag = [_unit] call FUNC(findMineMag);
if (_mag isEqualTo "") exitWith {};   // out of mines (processMineQueue also guards)

private _ammo = getText (configFile >> "CfgMagazines" >> _mag >> "ammo");
if (_ammo isEqualTo "") exitWith {};

private _pos = getPosATL _unit;
_unit removeMagazineGlobal _mag;

private _mine = createMine [_ammo, _pos, [], MINE_SKILL];
(side _unit) revealMine _mine;
_unit setUnitPosWeak "UP";

// A server-side createMine enters no curator's editable set, so Zeus would lose
// control of the mine. Grant it to every curator who can already edit the layer
// (keeps per-officer ownership); if none can, grant to all so it is never
// orphaned. Curator modules are server-local, so the direct call is valid here.
private _owners = allCurators select { !isNull _x && {_unit in curatorEditableObjects _x} };
if (_owners isEqualTo []) then { _owners = allCurators select { !isNull _x }; };
{ _x addCuratorEditableObjects [[_mine], false] } forEach _owners;
