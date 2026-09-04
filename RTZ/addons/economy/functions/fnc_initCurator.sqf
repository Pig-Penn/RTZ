#include "script_component.hpp"
/*
 * Author: Maxim
 * Sets up the economy on a curator module once per machine: the cost table and
 * placement/deletion event handlers everywhere, points and action coefficients
 * on the server.
 *
 * Runs regardless of the enable setting — a disabled economy still has to
 * register its (all zero) cost table and hand out its starting points,
 * otherwise the curator is left on whatever cost and point limits the
 * mission's Zeus module was configured with, which is not what "disabled"
 * should mean.
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

// All three fire on the machine of the player using the curator interface.
// Placing marks what the curator paid for and deleting refunds a share of it,
// which the engine's own "delete" coefficient cannot do selectively — see
// FUNC(markPlaced) and FUNC(refundDeleted).
_curator addEventHandler ["CuratorObjectRegistered", LINKFUNC(registerCosts)];
_curator addEventHandler ["CuratorObjectPlaced", LINKFUNC(markPlaced)];
_curator addEventHandler ["CuratorGroupPlaced", LINKFUNC(markPlaced)];
_curator addEventHandler ["CuratorObjectDeleted", LINKFUNC(refundDeleted)];

if (!isServer) exitWith {};

// Points and action coefficients live on the server
_curator addCuratorPoints ((GVAR(startingPoints) / POINTS_MAX) - curatorPoints _curator);
_curator setCuratorWaypointCost 0;
_curator allowCuratorLogicIgnoreAreas true;
_curator call FUNC(applyCoefs);
