#include "script_component.hpp"
/*
 * Author: Maxim
 * Sets up the economy on a curator module once per machine: the cost table
 * event handler everywhere, points and action coefficients on the server.
 *
 * Arguments:
 * 0: Curator module <OBJECT>
 *
 * Return Value:
 * None
 *
 * Example:
 * [_curator] call rtz_economy_fnc_initCurator
 *
 * Public: No
 */

params ["_curator"];

if (_curator getVariable [QGVAR(initialized), false]) exitWith {};
_curator setVariable [QGVAR(initialized), true];

// Fires on the machine of the player entering the curator interface
_curator addEventHandler ["CuratorObjectRegistered", {_this call FUNC(registerCosts)}];

if (!isServer) exitWith {};

// Points and action coefficients live on the server
_curator addCuratorPoints (1 - curatorPoints _curator);
_curator setCuratorWaypointCost 0;
_curator allowCuratorLogicIgnoreAreas true;
_curator call FUNC(applyCoefs);
