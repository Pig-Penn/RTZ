#include "script_component.hpp"
/*
 * Author: Maxim
 * Resolves a Zeus selection to a flat, unique list of objects the "Delete"
 * action may remove. Unlike EFUNC(common,collectUnits) this keeps whatever was
 * selected as-is — corpses and wrecks included — since the point is to clean
 * the battlefield, not to order living units around.
 *
 * A selected vehicle also contributes its crew (living and dead), so deleting
 * a wreck never leaves bodies floating where the hull used to be.
 *
 * Two things are always protected: players (and any vehicle carrying one, so a
 * curator can never delete a human out from under himself) and curator modules
 * (deleting one would strip that Zeus of his interface for the rest of the
 * mission).
 *
 * Arguments:
 * 0: Selected Objects <ARRAY>
 * 1: Selected Groups <ARRAY>
 *
 * Return Value:
 * Unique deletable objects <ARRAY>
 *
 * Example:
 * [_objects, _groups] call rtz_control_fnc_collectDeletables
 *
 * Public: No
 */

params ["_objects", ["_groups", []]];

// Selecting a group in the tree does not always list its units, so fold them in
private _candidates = +_objects;
{
    if (_x isEqualType grpNull) then {
        { _candidates pushBackUnique _x } forEach units _x;
    };
} forEach _groups;

private _targets = [];
{
    // Skip non-objects (a hovered waypoint/marker can arrive here via a modifier)
    if (_x isEqualType objNull && { !isNull _x } && { !(_x in allCurators) }) then {
        private _group = if (_x isKindOf "CAManBase") then { [_x] } else { [_x] + crew _x };

        // All-or-nothing per entry: a vehicle with a player aboard stays
        if (_group findIf { isPlayer _x } == -1) then {
            { _targets pushBackUnique _x } forEach _group;
        };
    };
} forEach _candidates;

_targets
