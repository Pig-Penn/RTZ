#include "script_component.hpp"
/*
 * Author: Maxim
 * Handler body for QGVAR(loadCasualtyMoveIn) (registered on EVERY machine in
 * XEH_postInit; the sender targets the event at the casualty, so it runs where
 * the casualty is local — required by moveInCargo). Thin tail of
 * FUNC(loadCasualtyApply): the server has already picked the vehicle and
 * updated the authoritative registry, so this just performs the seat.
 *
 * Arguments:
 * 0: The casualty <OBJECT>
 * 1: The medical vehicle to load him into <OBJECT>
 *
 * Return Value:
 * None
 *
 * Example:
 * [_unit, _veh] call rtz_casualty_fnc_loadCasualtyMoveIn
 *
 * Public: No
 */

params ["_unit", "_veh"];
if (isNull _unit || {isNull _veh} || {!alive _unit} || {!local _unit}) exitWith {};

_unit moveInCargo _veh;
