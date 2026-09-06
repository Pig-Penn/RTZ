#include "script_component.hpp"
/*
 * Author: Maxim
 * CLIENT. The Zeus-map half of the picker's service-radius ring. Attached as a
 * "Draw" handler on the curator map control by FUNC(orderResupply) and detached
 * again when the pick ends.
 *
 * Separate from FUNC(drawRing3D) because a RENDER_WORLD renderer is deliberately
 * skipped while the Zeus map covers the 3D view, and zen_common_fnc_selectPosition
 * works on the map as readily as in the world — so a picker with only the 3D ring
 * would lose its boundary exactly when the curator switched to the view that shows
 * a parked column best.
 *
 * Attached and detached BY ID rather than with ctrlRemoveAllEventHandlers, which
 * would take ZEN's own Draw handlers on the same control with it — including the
 * one selectPosition installs to draw the cursor this ring accompanies.
 *
 * Arguments:
 * 0: Zeus Map Control <CONTROL>
 *
 * Return Value:
 * None
 *
 * Example:
 * [_ctrlMap] call rtz_supply_fnc_drawRingMap
 *
 * Public: No
 */

params ["_ctrlMap"];

private _trucks = GVAR(ringTrucks);
if (_trucks isEqualTo []) exitWith {};

private _radius = GVAR(serviceRadius);

{
    if (isNull _x || {!alive _x}) then { continue };

    _ctrlMap drawEllipse [getPosVisual _x, _radius, _radius, 0, COLOR_RING, ""];
} forEach _trucks;
