#include "script_component.hpp"
/*
 * Author: Maxim
 * Sets up the economy on a curator module once per machine: the cost table
 * event handler everywhere, points and action coefficients on the server.
 *
 * Runs regardless of the enable setting — a disabled economy still has to
 * register its (all zero) cost table and hand out a full bar, otherwise the
 * curator is left on whatever cost and point limits the mission's Zeus module
 * was configured with, which is not what "disabled" should mean.
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

if (isNull _curator) exitWith {};
if (_curator getVariable [QGVAR(initialized), false]) exitWith {};
_curator setVariable [QGVAR(initialized), true];

// Fires on the machine of the player entering the curator interface
_curator addEventHandler ["CuratorObjectRegistered", LINKFUNC(registerCosts)];

if (!isServer) exitWith {};

// Points and action coefficients live on the server
_curator addCuratorPoints (1 - curatorPoints _curator);
_curator setCuratorWaypointCost 0;
_curator allowCuratorLogicIgnoreAreas true;
_curator call FUNC(applyCoefs);
