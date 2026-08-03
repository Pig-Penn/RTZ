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
 * Three things are always protected: players (and any vehicle carrying one, so
 * a curator can never delete a human out from under himself), curator modules
 * (deleting one would strip that Zeus of his interface for the rest of the
 * mission) and headless clients (deleting one takes every group it simulates
 * with it).
 *
 * Arguments:
 * 0: Selected Objects <ARRAY>
 * 1: Selected Groups <ARRAY> (default: [])
 * 2: Stop at the first deletable found <BOOL> (default: false)
 *
 * Return Value:
 * Unique deletable objects <ARRAY>
 *
 * Example:
 * [_objects, _groups] call rtz_delete_fnc_collectDeletables
 *
 * Public: No
 */

params ["_objects", ["_groups", []], ["_firstOnly", false]];

// Selecting a group in the tree does not always list its units, so fold them in
private _candidates = +_objects;
{
    if (_x isEqualType grpNull) then {
        { _candidates pushBackUnique _x } forEach units _x;
    };
} forEach _groups;

// Hoisted out of the candidate loop: both are engine scans that were previously
// re-run once per selected object, so a 200-object sweep paid for 200 of each.
private _protected = allCurators + (entities "HeadlessClient_F");

private _targets = [];
{
    // The context-menu condition only needs to know whether the list would be
    // non-empty; bailing here keeps a right-click on a large selection from
    // expanding every crew compartment for an answer it discards.
    //
    // `break`, and at the TOP of the body. This was an `exitWith {}` at the
    // BOTTOM, which is wrong twice over: exitWith inside a forEach exits only
    // the current ITERATION (it is continue, not break — docs/Knowledge Base/Gotchas.md §2), so
    // the loop ran on regardless, and sitting after the expansion it could not
    // have skipped the work it exists to skip even if it had broken. _firstOnly
    // was inert: every candidate's crew compartment was expanded every time.
    if (_firstOnly && { _targets isNotEqualTo [] }) then { break };

    // Skip non-objects (a hovered waypoint/marker can arrive here via a modifier)
    if (_x isEqualType objNull && { !isNull _x } && { !(_x in _protected) }) then {
        private _group = if (_x isKindOf "CAManBase") then { [_x] } else { [_x] + crew _x };

        // All-or-nothing per entry: a vehicle with a player aboard stays
        if (_group findIf { isPlayer _x } == -1) then {
            { _targets pushBackUnique _x } forEach _group;
        };
    };
} forEach _candidates;

_targets
